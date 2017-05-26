require 'bundler/setup'
require 'pg'

require_relative 'support/benchmark_pg'
require_relative 'support/pg_helper'

db = PG::Helper.connect

db.drop_and_create_table_users

1000.times do
  db.insert_user
end

Benchmark.pg("raw_pg/postgres_scope_all", time: 5) do
  str = ""
  db.all_users.each_row do |row|
    str << "name: #{row[0]} email: #{row[1]}\n"
  end
end

