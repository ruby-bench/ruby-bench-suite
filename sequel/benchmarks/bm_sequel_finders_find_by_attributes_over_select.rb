require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_finders_setup.rb"

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model; end

Benchmark.sequel("sequel/#{db_adapter}_finders_find_by_attributes_over_select", time: 5) do
  user = User.find(email: 'shatrov@me.com')
  str = "name: #{user.name} email: #{user.email}"
end
