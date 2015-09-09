require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name, :email
    t.timestamps null: false
  end

  add_index :users, :email, unique: true
end

class User < ActiveRecord::Base; end

1000.times do |i|
  User.create!({
    name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    email: "foobar#{"%03d" % i}@email.com"
  })
end

Benchmark.rails("activerecord/#{db_adapter}_scope_where", time: 5) do
  User.where(name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      .where("email LIKE :email", email: "foobar00%@email.com").to_a
end
