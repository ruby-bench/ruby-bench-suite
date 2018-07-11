require 'benchmark_driver/runner/time'

# For having a metric label compatible with RubyBench
class BenchmarkDriver::Runner::Seconds < BenchmarkDriver::Runner::Time
  METRIC = BenchmarkDriver::Metric.new(name: 'Execution time', unit: 'Seconds', larger_better: false)

  # JobParser returns this, `BenchmarkDriver::Runner.runner_for` searches "*::Job"
  Job = Class.new(BenchmarkDriver::DefaultJob)
  # Dynamically fetched and used by `BenchmarkDriver::JobParser.parse`
  JobParser = BenchmarkDriver::DefaultJobParser.for(klass: Job, metrics: [METRIC])

  # Overriding BenchmarkDriver::Runner::Ips#metric
  def metric
    METRIC
  end
end
