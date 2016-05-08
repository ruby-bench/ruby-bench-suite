# Running benchmarks locally

1. `RAILS_MASTER=1 bundle install`
2. `RAILS_MASTER=1 DATABASE_URL=sqlite3::memory: ruby benchmarks/bm_activerecord_destroy.rb` (specify your file instead of `bm_activerecord_destroy.rb`)
   `DATABASE_URL` key is required when running ActiveRecord benchmarks. Feel free to use any adapter (pg, mysql2, sqlite3)
3. Benchmark result will be printed as JSON.

# Adding new Rails benchmarks

Let's look at the sample Sprockets bench:

```ruby
require 'bundler/setup'

# we will use benchmark helper
require_relative 'support/benchmark_rails'
require 'sprockets'
require 'rack/builder'

app = Rack::Builder.new do
  map "/assets" do
    environment = Sprockets::Environment.new
    environment.append_path File.expand_path('../assets/javascripts', __FILE__)
    run environment
  end
end
request = Rack::MockRequest.env_for("/assets/application.js")

# pass benchmarkable code to the block.
# Benchmark.rails accepts benchmark key and duration in seconds.
Benchmark.rails("sprockets/simple", time: 5) do
  response = app.call(request)
  # assert that response code is successful
  raise "Request failed" unless response[0] == 200
end
```
