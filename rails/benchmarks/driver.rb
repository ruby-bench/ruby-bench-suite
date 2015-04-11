#
# Rails Benchmark driver
#
require 'net/http'
require 'json'
require 'pathname'
RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/'

Dir["#{File.expand_path(File.dirname(__FILE__))}/*"].select! { |path| path =~ /bm_+/ }.each do |path|
  # FIXME: ` provides the full output but it'll return failed output as well.
  output = JSON.parse(`DATABASE_URL=#{ENV['DATABASE_URL']} ruby #{path}`)

  http = Net::HTTP.new(ENV["API_URL"] || 'rubybench.org')
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

  request.set_form_data({
    'benchmark_type[category]' => output["label"],
    'benchmark_type[unit]' => 'iterations per second',
    'benchmark_type[script_url]' => "#{RAW_URL}#{Pathname.new(path).basename}",
    'benchmark_run[environment]' => "#{`ruby -v`}",
    'repo' => 'rails',
    'organization' => 'ruby'
  }.merge(initiator_hash).merge(results))

  http.request(request)
  puts "Posting results to Web UI...."
  puts "#{output["label"]} #{output["iterations_per_second"]}/ips"
end
