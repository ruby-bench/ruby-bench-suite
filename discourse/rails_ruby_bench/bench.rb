require 'socket'
require 'optparse'
require 'fileutils'
require 'net/http'
require 'digest'
require 'yaml'
require 'json'

@result_file = "benchmark_out.json"
@iterations = 3000
@rrb_dir = "../.."

opts = OptionParser.new do |o|
  o.banner = "Usage: ruby bench.rb [options]"

  o.on("-o", "--output [FILE]", "Output results to this file") do |f|
    @result_file = f
  end
  o.on("-i", "--iterations [ITERATIONS]", "Number of iterations to run the bench for") do |i|
    @iterations = i.to_i
  end
  o.on("-r", "--rrb-dir [PATH]", "Directory containing Rails Ruby Bench source") do |dir|
    @rrb_dir = dir
  end
end
opts.parse!

def run(command, opt = nil)
  exit_status =
    if opt == :quiet
      system(command, out: "/dev/null", err: :out)
    else
      system(command, out: $stdout, err: :out)
    end

  unless exit_status
    STDERR.puts "Bad exit status (#{exit_status.inspect} / #{$?.inspect}) for command #{command.inspect}. Exiting!"
    exit
  end
end

@timings = {}


def prereqs
  puts "Be sure to following packages are installed:

sudo apt-get -y install build-essential libssl-dev libyaml-dev git libtool libxslt-dev libxml2-dev libpq-dev gawk curl pngcrush python-software-properties software-properties-common tasksel

sudo tasksel install postgresql-server
OR
apt-get install postgresql-server^

sudo apt-add-repository -y ppa:rwky/redis
sudo apt-get update
sudo apt-get install redis-server
  "
end

puts "Ensuring config is setup"

ENV["RAILS_ENV"] = "profile"

def port_available? port
  server = TCPServer.open("0.0.0.0", port)
  server.close
  true
rescue Errno::EADDRINUSE
  false
end

@port = 60079

while !port_available? @port
  @port += 1
end

puts "Getting api key"
api_key = `bundle exec rake api_key:get`.split("\n")[-1]

def generate_digest
  Digest::SHA2.hexdigest("#{ENV['POSTGRES_ENV_PG_VERSION']}#{ENV['REDIS_ENV_REDIS_VERSION']}#{ENV['DISCOURSE_COMMIT_HASH']}#{ENV['RRB_COMMIT_HASH']}")
end

# critical cause cache may be incompatible
puts "precompiling assets"
run("bundle exec rake assets:precompile")

results = nil
Dir.chdir(@rrb_dir) do
  run "./start.rb -i #{@iterations} -o . -f #{@result_file}"
  results = JSON.load(File.read @result_file)
end

run("RAILS_ENV=profile bundle exec rake assets:clean")

ENVIRONMENT = results["settings"].merge(results["environment"])

def post_form_results(metric_name, category, result_type_name, result_type_units, value)
  http = Net::HTTP.new('rubybench.org')
  request = Net::HTTP::Post.new('/benchmark_runs')

  puts "Posting #{metric_name.inspect} results to Web UI...."
  form_results = {
    'benchmark_result_type[name]' => result_type_name,
    'benchmark_result_type[unit]' => result_type_units,
    "benchmark_run[result][#{metric_name}]" => value,
    'benchmark_type[category]' => category,
    'benchmark_type[script_url]' => "https://raw.githubusercontent.com/noahgibbs/rails_ruby_bench/#{ENV['RRB_COMMIT_HASH']}/start.rb",
    'benchmark_type[digest]' => generate_digest,
    'benchmark_run[environment]' => ENVIRONMENT.to_yaml,
    'repo' => 'ruby',
    'organization' => 'ruby'
  }
  if ENV['RUBY_COMMIT_HASH']
    form_results["commit_hash"] = ENV['RUBY_COMMIT_HASH']
  elsif ENV['RUBY_VERSION']
    form_results["version"] = ENV['RUBY_VERSION']
  end

  request.set_form_data(form_results)
  request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])
  http.request(request)
end

def percentile(list, pct)
  len = list.length
  how_far = pct * 0.01 * (len - 1)
  prev_item = how_far.to_i
  return list[prev_item] if prev_item >= len - 1
  return list[0] if prev_item < 0

  linear_combination = how_far - prev_item
  list[prev_item] + (list[prev_item + 1] - list[prev_item]) * linear_combination
end

puts "Reporting metrics..."
times = results["requests"]["times"].flatten.sort
runs = results["requests"]["times"].map { |thread_times| thread_times.inject(0.0, &:+) }.sort
startups = results["startup"]["times"]

throughput = times.flatten.size / runs.max  # Total # of requests over longest thread-runtime = req/sec

post_form_results "throughput", "rails_ruby_bench_throughput", "Number of iterations per second", "Iterations per second", throughput
post_form_results "run minimum", "rails_ruby_bench_thread_runs", "Execution time", "Seconds", runs[0]
post_form_results "run maximum", "rails_ruby_bench_thread_runs", "Execution time", "Seconds", runs[-1]

post_form_results "median request", "rails_ruby_bench_requests", "Execution time", "Seconds", percentile(times, 50)
[0, 5, 10, 25, 75, 90, 95, 100].each do |percentile|
  post_form_results "request #{percentile}% percentile", "rails_ruby_bench_requests", "Execution time", "Seconds", percentile(times, percentile)
end
