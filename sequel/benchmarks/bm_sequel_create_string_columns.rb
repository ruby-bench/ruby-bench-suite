require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_create_string_columns_setup.rb"

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model
  self.raise_on_save_failure = true
  plugin :timestamps, update_on_create: true
end

attributes = {}

25.times do |i|
  attributes[:"column#{i}"] = "Some string #{i}"
end

Benchmark.sequel("sequel/#{db_adapter}_create_string_columns", time: 5) do
  User.create(attributes)
end
