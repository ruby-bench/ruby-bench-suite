require 'bundler/setup'
require 'pg'
require_relative 'support/benchmark_pg'

conn = PG.connect(ENV.fetch("DATABASE_URL"))

conn.exec("DROP TABLE IF EXISTS users;")
conn.exec("CREATE TABLE users ( name varchar(255), email varchar(255), created_at timestamp, updated_at timestamp );")

1000.times do
  conn.exec("INSERT INTO users VALUES ('Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'foobar@email.com');")
end

Benchmark.pg("pg/scope_all", time: 5) do
  str = ""
  conn.exec("SELECT * FROM users").each_row{ |row| str << "name: #{row[0]} email: #{row[1]}\n" }
end

