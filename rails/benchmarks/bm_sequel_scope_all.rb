require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_rails'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

DB.create_table(:users) do
  primary_key :id
  column :name, "varchar(255)"
  column :email, "varchar(255)"
  column :created_at, "timestamp"
  column :updated_at, "timestamp"
end

class User < Sequel::Model; end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

1000.times do
  User.create(attributes)
end

Benchmark.rails("sequel/#{db_adapter}_scope_all", time: 5) do
  User.all.to_a
end
