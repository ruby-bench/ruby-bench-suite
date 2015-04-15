require 'bundler/setup'
require 'rails'
require 'active_record'

require_relative 'support/benchmark_rails.rb'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name, :email
    t.boolean :admin
    t.timestamps null: false
  end
end

class User < ActiveRecord::Base
  default_scope { where(admin: true) }
end

admin = true

1000.times do
  attributes = {
    name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    email: "foobar@email.com",
    admin: admin
  }

  User.create!(attributes)

  admin = !admin
end

Benchmark.rails("activerecord/sqlite3_finders_all", time: 10) do
  User.all
end
