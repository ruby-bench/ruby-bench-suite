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
class BenchmarkDriver::Output::Rubybench < BenchmarkDriver::BulkOutput
  # For maintainability, this doesn't support streaming progress output.
  # @param [Hash{ BenchmarkDriver::Job => Hash{ BenchmarkDriver::Context => { BenchmarkDriver::Metric => Float } } }] result
  # @param [Array<BenchmarkDriver::Metric>] metrics
  def bulk_output(result:, metrics:)
    metrics.each do |metric|
      result.each do |job, context_metric_value|
        context_value = {}
        context_metric_value.each do |context, metric_value|
          if metric_value.key?(metric)
            context_value[context] = metric_value[metric]
          end
        end

        create_benchmark_run(job, metric, context_value)
      end
    end
  end

  private

  # Create BenchmarkRun record on RubyBench
  # @param [BenchmarkDriver::Job] job
  # @param [BenchmarkDriver::Metric] metric
  # @param [Hash{ BenchmarkDriver::Context => Float }] context_value
  def create_benchmark_run(job, metric, context_value)
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
    context_value.each do |context, value|
      initiator_hash["benchmark_run[result][#{context.name}]"] = value
    end

    context = context_value.keys.first
    ruby_version = IO.popen([*context.executable.command, '-v'], &:read)

    request.set_form_data({
      'benchmark_result_type[name]' => metric.name,
      'benchmark_result_type[unit]' => metric.unit,
      'benchmark_type[category]' => job.name,
      'benchmark_type[script_url]' => ENV.fetch('BENCHMARK_TYPE_SCRIPT_URL'),
      'benchmark_type[digest]' => ENV.fetch('BENCHMARK_TYPE_DIGEST'),
      'benchmark_run[environment]' => { 'Ruby version' => ruby_version }.merge(context.environment).to_yaml,
      'repo' => ENV.fetch('REPO_NAME'),
      'organization' => ENV.fetch('ORGANIZATION_NAME'),
    }.merge(initiator_hash).merge(result_hash))

    puts http.request(request).body
  end
end
