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

Benchmark.rails("sequel/#{db_adapter}_destroy", time: 5) do
  # we need to create the record in order to delete it
  user = User.create(attributes)
  user.destroy
end
