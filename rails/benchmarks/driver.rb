#
# Rails Benchmark driver
#
require 'net/http'
require 'json'
require 'pathname'
require 'optparse'

RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/rails/benchmarks/'

ORMS = [
  "sqlite3://:@localhost/:memory:",
  "postgres://postgres@#{ENV['POSTGRES_PORT_5432_TCP_ADDR']}:#{ENV['POSTGRES_PORT_5432_TCP_PORT']}/rubybench",
  "mysql://rubybench@#{ENV['MYSQL_PORT_3306_TCP_ADDR']}:#{ENV['MYSQL_PORT_3306_TCP_PORT']}/rubybench",
]

class BenchmarkDriver
  def self.benchmark(options)
    self.new(options).run
  end

  def initialize(options)
    @repeat_count = options[:repeat_count]
  end

  def run
    files.each do |path|
      if path.match(/activerecord/)
        ORMS.each do |url|
          run_single(path, connection: url)
        end
      else
        run_single(path)
      end
    end
  end

  private

  def files
    Dir["#{File.expand_path(File.dirname(__FILE__))}/*"].select! { |path| path =~ /bm_.+/ }
  end

  def run_single(path, connection: nil)
    script = "RAILS_ENV=production ruby #{path}"
    if connection
      script = "DATABASE_URL=#{connection} #{script}"
    end

    # FIXME: ` provides the full output but it'll return failed output as well.
    output = measure(script)

    request = Net::HTTP::Post.new('/benchmark_runs')
    request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])

    initiator_hash = {}
    if(ENV['RAILS_COMMIT_HASH'])
      initiator_hash['commit_hash'] = ENV['RAILS_COMMIT_HASH']
    elsif(ENV['RAILS_VERSION'])
      initiator_hash['version'] = ENV['RAILS_VERSION']
    end

    results = {
      "benchmark_run[result][iterations_per_second]" => output["iterations_per_second"].round(3),
      "benchmark_run[result][total_allocated_objects_per_iteration]" => output["total_allocated_objects_per_iteration"]
    }

    submit = {
      'benchmark_type[category]' => output["label"],
      'benchmark_type[unit]' => 'iterations per second',
      'benchmark_type[script_url]' => "#{RAW_URL}#{Pathname.new(path).basename}",
      'benchmark_run[environment]' => "#{`ruby -v`}",
      'repo' => 'rails',
      'organization' => 'rails'
    }.merge(initiator_hash).merge(results)
    request.set_form_data(submit)

    endpoint.request(request)
    puts "Posting results to Web UI...."
  end

  def endpoint
    @endpoint ||= Net::HTTP.new(ENV["API_URL"] || 'rubybench.org')
  end

  def measure(script)
    results = []

    @repeat_count.times do
      result = JSON.parse(`#{script}`)
      puts "#{result["label"]} #{result["iterations_per_second"]}/ips"
      results << result
    end

    results.sort_by do |result|
      result['iterations_per_second']
    end.last
  end
end

options = {
  repeat_count: 1
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby driver.rb [options]"

  opts.on("-r", "--repeat-count [NUM]", "Run benchmarks [NUM] times taking the best result") do |value|
    options[:repeat_count] = value.to_i
  end
end.parse!(ARGV)

BenchmarkDriver.benchmark(options)
