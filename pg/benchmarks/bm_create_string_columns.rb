require 'bundler/setup'
require 'pg'
require_relative 'support/benchmark_pg'

db_setup script: "bm_create_string_columns_setup.rb"

connection = PG.connect(ENV.fetch("DATABASE_URL"))

query = "INSERT INTO users ("
STRING_COLUMNS_COUNT.times do |i|
  query << "column#{i} ,"
end
query << "created_at, updated_at) "
query << "VALUES ("
STRING_COLUMNS_COUNT.times do |i|
   query << "'Some string #{i}', "
end
query << "'#{DateTime.now}', '#{DateTime.now}'"
query << ");"

Benchmark.pg("pg/create_string_columns", time: 5) do
  connection.exec(query)
end
