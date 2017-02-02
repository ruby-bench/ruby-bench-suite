require_relative 'benchmark_liquid'
require_relative 'liquid/performance/theme_runner'

profiler = ThemeRunner.new

Benchmark.liquid("render") do
  profiler.render
end
