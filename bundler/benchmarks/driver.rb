#
# Bundler Benchmark driver
#
require 'net/http'
require 'json'
require 'pathname'
require 'optparse'
require 'digest'

RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/bundler/benchmarks/'

class BenchmarkDriver
  def self.benchmark(options)
    self.new(options).run
  end

  def initialize(options)
    @repeat_count = options[:repeat_count]
    @pattern = options[:pattern]
    @local = options[:local]
  end

  def run
    files.each do |path|
      next if !@pattern.empty? && /#{@pattern.join('|')}/ !~ File.basename(path)
      run_single(path)
    end
  end

  private

  def files
    Pathname.glob("#{File.expand_path(File.dirname(__FILE__))}/bm_*")
  end

  def bundler_lib
    lib = [ENV['BUNDLER_LIB'], Pathname(`gem which bundler`.strip).dirname]
      .find { |p| p && File.directory?(p) }
    Pathname(lib)
  end

  def run_single(path)
    script = "RUBYOPT=-I'#{bundler_lib.expand_path}' ruby '#{path}'"

    # FIXME: ` provides the full output but it'll return failed output as well.
    output = measure(script)
    return unless output

    request = Net::HTTP::Post.new('/benchmark_runs')
    request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])

    initiator_hash = {}
    if(ENV['BUNDLER_COMMIT_HASH'])
      initiator_hash['commit_hash'] = ENV['BUNDLER_COMMIT_HASH']
    elsif(ENV['BUNDLER_VERSION'])
      initiator_hash['version'] = ENV['BUNDLER_VERSION']
    end

    submit = {
      'benchmark_type[category]' => output["label"],
      'benchmark_type[script_url]' => "#{RAW_URL}#{path.basename}",
      'benchmark_type[digest]' => generate_digest(path),
      'benchmark_run[environment]' => "#{`ruby -v; gem -v`.strip}",
      'repo' => 'bundler',
      'organization' => 'bundler'
    }.merge(initiator_hash)

    request.set_form_data(submit.merge(
      {
        "benchmark_run[result][iterations_per_second]" => output["iterations_per_second"].round(3),
        'benchmark_result_type[name]' => 'Number of iterations per second',
        'benchmark_result_type[unit]' => 'Iterations per second'
      }
    ))

    endpoint.request(request) unless @local

    request.set_form_data(submit.merge(
      {
        "benchmark_run[result][total_allocated_objects_per_iteration]" => output["total_allocated_objects_per_iteration"],
        'benchmark_result_type[name]' => 'Allocated objects',
        'benchmark_result_type[unit]' => 'Objects'
      }
    ))

    if @local
      puts output
    else
      endpoint.request(request)
      puts "Posting results to Web UI...."
    end
  end

  def generate_digest(path)
    Digest::SHA2.hexdigest("#{File.read(path)}#{`ruby -v; gem -v`}")
  end

  def endpoint
    @endpoint ||= begin
      http = Net::HTTP.new(ENV["API_URL"] || 'rubybench.org', 443)
      http.use_ssl = true
      http
    end
  end

  def measure(script)
    begin
      results = []

      @repeat_count.times do
        result = JSON.parse(`#{script}`)
        puts "#{result["label"]} #{result["iterations_per_second"]}/ips"
        results << result
      end

      results.sort_by do |result|
        result['iterations_per_second']
      end.last
    rescue JSON::ParserError
      # Do nothing
    end
  end
end

options = {
  repeat_count: 1,
  pattern: [],
  local: false,
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby driver.rb [options]"

  opts.on("-r", "--repeat-count [NUM]", "Run benchmarks [NUM] times taking the best result") do |value|
    options[:repeat_count] = value.to_i
  end

  opts.on("-p", "--pattern <PATTERN1,PATTERN2,PATTERN3>", "Benchmark name pattern") do |value|
    options[:pattern] = value.split(',')
  end

  opts.on("--local", "Don't report benchmark results to the server") do |value|
    options[:local] = value
  end
end.parse!(ARGV)

BenchmarkDriver.benchmark(options)
