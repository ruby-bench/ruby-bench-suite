require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_finders_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

Benchmark.rails("activerecord/#{db_adapter}_pluck", time: 5) do
  user = User.find_by("email = :email", email: 'foobar@email.com')
  str = "#{user.email} #{user.name}"
end
