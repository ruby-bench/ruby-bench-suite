# This file is auto-loaded by `BenchmarkDriver::Output` when `-o rubybench` is specified.
require 'benchmark_driver'
require 'net/http'

# Common environment variables:
#   API_URL=rubybench.org
#   API_NAME
#   API_PASSWORD
#   RUBY_COMMIT_HASH or RUBY_VERSION
# Benchmark-specific environment variables:
#   BENCHMARK_TYPE_SCRIPT_URL
#   BENCHMARK_TYPE_DIGEST
#   REPO_NAME
#   ORGANIZATION_NAME
# Optional environment variables:
#   RUBY_ENVIRONMENT
class BenchmarkDriver::Output::Rubybench < BenchmarkDriver::BulkOutput
  # For maintainability, this doesn't support streaming progress output.
  # @param [Hash{ BenchmarkDriver::Job => Hash{ BenchmarkDriver::Context => BenchmarkDriver::Result } }] job_context_result
  # @param [Array<BenchmarkDriver::Metric>] metrics
  def bulk_output(job_context_result:, metrics:)
    metrics.each do |metric|
      job_context_result.each do |job, context_result|
        create_benchmark_run(job, metric, context_result)
      end
    end
  end

  private

  # Create BenchmarkRun record on RubyBench
  # @param [BenchmarkDriver::Job] job
  # @param [BenchmarkDriver::Metric] metric
  # @param [Hash{ BenchmarkDriver::Context => BenchmarkDriver::Result }] context_result
  def create_benchmark_run(job, metric, context_result)
    http = Net::HTTP.new(ENV.fetch('API_URL', 'rubybench.org'), 443)
    http.use_ssl = true
    request = Net::HTTP::Post.new('/benchmark_runs')
    request.basic_auth(ENV.fetch('API_NAME'), ENV.fetch('API_PASSWORD'))

    initiator_hash = {}
    if ENV.key?('RUBY_COMMIT_HASH')
      initiator_hash['commit_hash'] = ENV['RUBY_COMMIT_HASH']
    elsif ENV.key?('RUBY_VERSION')
      initiator_hash['version'] = ENV['RUBY_VERSION']
    end

    result_hash = {}
    context_result.each do |context, result|
      initiator_hash["benchmark_run[result][#{context.name}]"] = result.values.fetch(metric)
    end

    ruby_version = context_result.keys.first.executable.description
    if ENV['RUBY_ENVIRONMENT'] == 'true'
      environment = ruby_version
    else
      environment = { 'Ruby version' => ruby_version }.merge(context_result.values.first.environment).to_yaml
    end

    request.set_form_data({
      'benchmark_result_type[name]' => metric.name,
      'benchmark_result_type[unit]' => metric.unit,
      'benchmark_type[category]' => job.name,
      'benchmark_type[script_url]' => ENV.fetch('BENCHMARK_TYPE_SCRIPT_URL'),
      'benchmark_type[digest]' => ENV.fetch('BENCHMARK_TYPE_DIGEST'),
      'benchmark_run[environment]' => environment,
      'repo' => ENV.fetch('REPO_NAME'),
      'organization' => ENV.fetch('ORGANIZATION_NAME'),
    }.merge(initiator_hash).merge(result_hash))

    response = http.request(request)
    puts "status: #{response.code}, body: #{response.body.inspect}"
  end
end
