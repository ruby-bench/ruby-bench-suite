require 'bundler/setup'
require 'sprockets'
require_relative 'support/benchmark_rails'
require 'rack/builder'

app = Rack::Builder.new do
  map "/assets" do
    environment = Sprockets::Environment.new
    environment.append_path File.expand_path('../assets/javascripts', __FILE__)
    run environment
  end
end
request = Rack::MockRequest.env_for("/assets/application.js")

Benchmark.rails("sprockets/simple", time: 3.seconds) do
  response = app.call(request)
  raise "request is broken" unless response[0] == 200
end
