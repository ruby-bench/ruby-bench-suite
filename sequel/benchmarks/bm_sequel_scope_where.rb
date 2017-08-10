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

DB.add_index :users, :email, unique: true

class User < Sequel::Model
  self.raise_on_save_failure = true
end

1000.times do |i|
  User.create({
    name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    email: "foobar#{"%03d" % i}@email.com"
  })
end

Benchmark.sequel("sequel/#{db_adapter}_scope_where", time: 5) do
  str = ""
  User
    .where(name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    .where(Sequel.lit('email LIKE ?', 'foobar00%@email.com'))
    .each { |user| str << "name: #{user.name} email: #{user.email}\n" }
end
