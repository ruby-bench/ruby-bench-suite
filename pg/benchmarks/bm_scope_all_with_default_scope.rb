require 'bundler/setup'
require 'pg'

require_relative 'support/benchmark_pg'
require_relative 'support/pg_helper'

db = PG::Helper.connect

db.drop_and_create_table_users

500.times do
  db.insert_user
end

500.times do
  db.insert_admin
end

Benchmark.pg("raw_pg/postgres_scope_all_with_default_scope", time: 5) do
  str = ""
  db.all_admins.each do |admin|
    str << "name: #{admin["name"]} email: #{admin["email"]}\n"
  end
end

