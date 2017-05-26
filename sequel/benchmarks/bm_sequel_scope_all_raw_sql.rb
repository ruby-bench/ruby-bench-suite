require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

DB.create_table!(:users) do
  primary_key :id
  String :name, size: 255
  String :email, size: 255
  DateTime :created_at, null: true
  DateTime :updated_at, null: true
end

class User < Sequel::Model
  self.raise_on_save_failure = true
  self.set_allowed_columns :name, :email, :created_at, :updated_at
end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

1000.times do
  User.create(attributes)
end

Benchmark.sequel("sequel/#{db_adapter}_scope_all_raw_sql", time: 5) do
  str = ""
  DB.fetch("SELECT * FROM users").each do |user|
    str << "name: #{user["name"]} email: #{user["email"]}\n"
  end
end
