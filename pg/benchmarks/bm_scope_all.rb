require 'bundler/setup'
require 'pg'
require_relative 'support/benchmark_pg'

conn = PG.connect(
  host: ENV.fetch("HOST", "localhost"),
  port: ENV.fetch("PORT", "5432"),
  dbname: ENV.fetch("DB_NAME", "rubybench"),
  user: ENV.fetch("DB_USER", "postgres"),
  password: ENV.fetch("DB_PASSWORD", "postgres")
)

conn.exec("DROP TABLE IF EXISTS users;")
conn.exec("CREATE TABLE users ( name varchar(255), email varchar(255), created_at timestamp, updated_at timestamp );")

1000.times do
  conn.exec("INSERT INTO users VALUES ('Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'foobar@email.com');")
end

Benchmark.pg("pg/scope_all", time: 5) do
  str = ""
  conn.exec("SELECT * FROM users").each_row{ |row| str << "name: #{row[0]} email: #{row[1]}\n" }
end

