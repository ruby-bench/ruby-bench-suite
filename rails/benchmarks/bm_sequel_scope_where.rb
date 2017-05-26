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

DB.add_index :users, :email, :unique => true

class User < Sequel::Model; end

1000.times do |i|
  User.create({
    name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    email: "foobar#{"%03d" % i}@email.com"
  })
end

Benchmark.rails("sequel/#{db_adapter}_scope_where", time: 5) do
  User.where(name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      .where(Sequel.ilike(:email, 'foobar00%@email.com')).to_a
end
