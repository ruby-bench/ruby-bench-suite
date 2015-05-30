require_relative 'support/benchmark_bundler.rb'

gemfile = proc do
  source "https://rubygems.org"

  gem "sass-rails"
  gem "rails", "~> 3"
  gem "gxapi_rails"
end

Benchmark.resolve_definition('gxapi_rails', gemfile)
