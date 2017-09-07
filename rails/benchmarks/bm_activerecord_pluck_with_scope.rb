require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_finders_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

last_user_id = User.last.id

Benchmark.rails("activerecord/#{db_adapter}_pluck_with_scope", time: 5) do
  User.where(id: last_user_id).pluck(:name)
end
