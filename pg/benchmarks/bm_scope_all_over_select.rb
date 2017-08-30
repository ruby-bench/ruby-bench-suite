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

  i = 0
  while i < result.ntuples do
    str << "name: #{result.getvalue(i, 0)} email: #{result.getvalue(i, 1)} approved: #{result.getvalue(i, 2)} age: #{result.getvalue(i, 3)} birthday: #{result.getvalue(i, 4)} \n"
    i += 1
  end
end

