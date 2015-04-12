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
    t.timestamps null: false
  end
end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com",
  created_at: Date.today
}

class User < ActiveRecord::Base; end

Benchmark.rails("activerecord/sqlite3_save", time: 10) do
  user = User.new(attributes)

  unless user.save
    raise "should save correctly"
  end
end
