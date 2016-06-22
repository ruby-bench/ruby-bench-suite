require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

COUNT=25

DB.create_table(:users) do
  primary_key :id
  COUNT.times do |i|
    String :"column#{i}", size: 255
  end
  DateTime :created_at, null: true
  DateTime :updated_at, null: true
end

class User < Sequel::Model
  self.raise_on_save_failure = true
  self.set_allowed_columns *columns[1..-1]
end

attributes = {}

COUNT.times do |i|
  attributes[:"column#{i}"] = "Some string #{i}"
end

Benchmark.sequel("sequel/#{db_adapter}_create_string_columns", time: 5) do
  User.create(attributes)
end
