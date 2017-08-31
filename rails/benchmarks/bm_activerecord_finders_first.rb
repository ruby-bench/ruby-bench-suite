require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_finders_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

Benchmark.rails("activerecord/#{db_adapter}_finders_first", time: 5) do
  user = User.select(:name, :email).first
  str = "name: #{user.name} email: #{user.email}"
end
