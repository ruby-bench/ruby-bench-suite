require 'bundler/setup'
require 'action_controller'
require_relative 'support/benchmark_rails'

class ApiController < ActionController::API
  def show
    render json: "JSON", status: :ok
  end
end
app = ApiController.action(:show)
request = Rack::MockRequest.new(app)
Benchmark.rails("actioncontroller/api", time: 5) do
  response = request.get("/")
  fail "Bad response #{response.status}" if response.status != 200
  fail "Bad response #{response.body}" if response.body != "JSON"
end
