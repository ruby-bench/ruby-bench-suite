require 'bundler/setup'
require 'rails'

require_relative 'support/benchmark_rails.rb'
require_relative 'support/actioncable_helpers.rb'

PG_FAYE = Faye::WebSocket::Client.new("ws://127.0.0.1:4001/")

pg_tcp_addr = ENV['POSTGRES_PORT_5432_TCP_ADDR'] || 'localhost'
pg_port = ENV['POSTGRES_PORT_5432_TCP_PORT'] || 5432
PG_DB_URL = "postgres://postgres@#{pg_tcp_addr}:#{pg_port}/rubybench",

Benchmark.rails("actioncable_postgres", time: 10) do
  pg_config =  { adapter: 'postgresql', url: PG_DB_URL }.with_indifferent_access
  with_puma_server(ActionCable.server, 4001, pg_config) do |port|
    500.times do
      PG_FAYE.send(SUB)
      PG_FAYE.send(MSG)
    end
  end
end
