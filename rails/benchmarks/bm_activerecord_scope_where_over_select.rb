require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_scope_where_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

Benchmark.rails("activerecord/#{db_adapter}_scope_where", time: 5) do
  str = ""
  User
    .where(name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    .where("email LIKE :email", email: "foobar00%@email.com")
    .each { |user| str << "name: #{user.name} email: #{user.email}\n" }
end
