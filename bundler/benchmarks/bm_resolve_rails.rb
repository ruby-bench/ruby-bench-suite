require_relative 'support/benchmark_bundler.rb'

gemfile = proc do
  source :rubygems
  gem 'rails'
end

Benchmark.resolve_definition('rails', gemfile)
