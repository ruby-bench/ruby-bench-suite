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
end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

Benchmark.sequel("sequel/#{db_adapter}_save", time: 5) do
  user = User.new(attributes)
  user.save
end
