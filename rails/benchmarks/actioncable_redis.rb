require 'bundler/setup'
require 'rails'

require_relative 'support/benchmark_rails.rb'
require_relative 'support/actioncable_helpers.rb'

REDIS_FAYE = Faye::WebSocket::Client.new("ws://127.0.0.1:4002/")

REDIS_DB_URL = ENV["REDIS_PORT_6379_TCP_ADDR"]

Benchmark.rails("actioncable_redis", time: 10) do
  redis_config =  { adapter: 'redis', url: REDIS_DB_URL }.with_indifferent_access
  with_puma_server(ActionCable.server, 4002, redis_config) do |port|
    500.times do
      REDIS_FAYE.send(SUB)
      REDIS_FAYE.send(MSG)
    end
  end
end
