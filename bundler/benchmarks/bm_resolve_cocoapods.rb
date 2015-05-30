require_relative 'support/benchmark_bundler.rb'

gemfile = proc do
  source :rubygems
  gem 'cocoapods'
end

Benchmark.resolve_definition('cocoapods', gemfile)
