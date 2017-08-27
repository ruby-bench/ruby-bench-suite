require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_create_string_columns_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

attributes = {}

25.times do |i|
  attributes[:"column#{i}"] = "Some string #{i}"
end

Benchmark.rails("activerecord/#{db_adapter}_create_string_columns", time: 5) do
  User.create!(attributes)
end
