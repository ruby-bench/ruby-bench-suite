require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_rails'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

COUNT=25 

DB.create_table(:users) do
  primary_key :id
    COUNT.times do |i|
      column :"column#{i}", "varchar(255)"
    end
    column :created_at, "timestamp"
    column :updated_at, "timestamp"
end

class User < Sequel::Model; end

attributes = {}

COUNT.times do |i|
  attributes[:"column#{i}"] = "Some string #{i}"
end

Benchmark.rails("sequel/#{db_adapter}_create_string_columns", time: 5) do
  User.create(attributes)
end

