require 'bundler/setup'
require 'pg'
require_relative 'support/benchmark_pg'

db_setup script: "bm_scope_all_setup.rb"

connection = PG.connect(ENV.fetch("DATABASE_URL"))
type_mapper = PG::BasicTypeMapForResults.new(connection)

Benchmark.pg("pg/scope_all_over_select", time: 5) do
  str = ""

  result = connection.exec("SELECT * FROM users")
  result.type_map = type_mapper
  
  result.each_row do |row| 
    str << "name: #{row[0]} email: #{row[1]} approved: #{row[2]} age: #{row[3]} birthday: #{row[4]} \n"
  end
end

