require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_scope_where_setup.rb"

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model; end

Benchmark.sequel("sequel/#{db_adapter}_scope_where_over_select", time: 5) do
  str = ""
  User
    .where(name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    .where(Sequel.lit('email LIKE ?', 'foobar00%@email.com'))
    .each { |user| str << "name: #{user.name} email: #{user.email}\n" }
end
