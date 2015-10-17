require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Migration.verbose = false

COUNT = 25

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    COUNT.times do |i|
      t.string :"column#{i}"
    end

    t.timestamps null: false
  end
end

class User < ActiveRecord::Base; end

attributes = {}

COUNT.times do |i|
  attributes[:"column#{i}"] = "Some string #{i}"
end

Benchmark.rails("activerecord/#{db_adapter}_create_string_columns", time: 5) do
  User.create!(attributes)
end
