#
# Rails Benchmark driver
#
require 'bundler/setup'
require 'net/http'
require 'json'
require 'pathname'
require 'optparse'
require 'rails'
require 'digest'

RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/rails/benchmarks/'

postgres_tcp_addr = ENV['POSTGRES_PORT_5432_TCP_ADDR'] || 'localhost'
postgres_port = ENV['POSTGRES_PORT_5432_TCP_PORT'] || 5432
mysql_tcp_addr = ENV['MYSQL_PORT_3306_TCP_ADDR'] || 'localhost'
mysql_port = ENV['MYSQL_PORT_3306_TCP_PORT'] || 3306

DATABASE_URLS = {
  psql: "postgres://postgres:1111111111@#{postgres_tcp_addr}:#{postgres_port}/rubybench",
  mysql: "mysql2://root@#{mysql_tcp_addr}:#{mysql_port}/rubybench",
}

class BenchmarkDriver
  def self.benchmark(options)
    self.new(options).run
  end

  def initialize(options)
    @repeat_count = options[:repeat_count]
    @pattern = options[:pattern]
  end

  def run
    files.each do |path|
      next if !@pattern.empty? && /#{@pattern.join('|')}/ !~ File.basename(path)

      if path.match(/activerecord|scaffold/)
        DATABASE_URLS.each do |database, url|
          run_single(path, connection: url, database: database)
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

  def run_single(path, connection: nil, database: nil)
    script = "RAILS_ENV=production ruby #{path}"
    if connection
      script = "DATABASE_URL=#{connection} #{script}"
    end

    # FIXME: ` provides the full output but it'll return failed output as well.
    output = measure(script)
    return unless output

    request = Net::HTTP::Post.new('/benchmark_runs')
    request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])

    initiator_hash = {}
    if(ENV['RAILS_COMMIT_HASH'])
      initiator_hash['commit_hash'] = ENV['RAILS_COMMIT_HASH']
    elsif(ENV['RAILS_VERSION'])
      initiator_hash['version'] = ENV['RAILS_VERSION']
    end

    submit = {
      'benchmark_type[category]' => output.delete("label"),
      'benchmark_type[script_url]' => "#{RAW_URL}#{Pathname.new(path).basename}",
      'benchmark_type[digest]' => generate_digest(path, database),
      'benchmark_run[environment]' => "#{`ruby -v`}",
      'repo' => 'rails',
      'organization' => 'rails'
    }.merge(initiator_hash)

    form_results = {}

    output.each do |result_label, output|
      form_results["benchmark_run[result][#{result_label}]"] = output["iterations_per_second"].round(3)
    end

    request.set_form_data(submit.merge(form_results.merge({
        'benchmark_result_type[name]' => 'Number of iterations per second',
        'benchmark_result_type[unit]' => 'Iterations per second'
    })))

    endpoint.request(request)

    form_results = {}

    output.each do |result_label, output|
      form_results["benchmark_run[result][#{result_label}]"] = output["total_allocated_objects_per_iteration"].round(3)
    end

    request.set_form_data(submit.merge(form_results.merge({
      'benchmark_result_type[name]' => 'Allocated objects',
      'benchmark_result_type[unit]' => 'Objects'
    })))

    endpoint.request(request)

    puts "Posting results to Web UI...."
  end

  def endpoint
    @endpoint ||= begin
      http = Net::HTTP.new(ENV["API_URL"] || 'rubybench.org', 443)
      http.use_ssl = true
      http
    end
  end

  def generate_digest(path, database)
    string = "#{File.read(path)}#{`ruby -v`}"

    case database
    when 'psql'
      string = "#{string}#{ENV['POSTGRES_ENV_PG_VERSION']}"
    when 'mysql'
      string = "#{string}#{ENV['MYSQL_ENV_MYSQL_VERSION']}"
    end

    Digest::SHA2.hexdigest(string)
  end

  def measure(script)
    begin
      results = {}
      label = nil

      @repeat_count.times do
        result = JSON.parse(`#{script}`)

        label ||= result['label']
        puts result["label"]
        result["results"].each do |result_label, output|
          puts "#{result_label} #{output["iterations_per_second"]}/ips"
          results[result_label] ||= []
          results[result_label] << output
        end
      end

      results = results.each do |result_label, outputs|
        results[result_label] = outputs.sort_by do |output|
          output['iterations_per_second']
        end.last
      end.merge({ "label" => label })

      results
    rescue JSON::ParserError
      # Do nothing
    end
  end
end

options = {
  repeat_count: 1,
  pattern: []
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby driver.rb [options]"

  opts.on("-r", "--repeat-count [NUM]", "Run benchmarks [NUM] times taking the best result") do |value|
    options[:repeat_count] = value.to_i
  end

  opts.on("-p", "--pattern <PATTERN1,PATTERN2,PATTERN3>", "Benchmark name pattern") do |value|
    options[:pattern] = value.split(',')
  end
end.parse!(ARGV)

BenchmarkDriver.benchmark(options)
