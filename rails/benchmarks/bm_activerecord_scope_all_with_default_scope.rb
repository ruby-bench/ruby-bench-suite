require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

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

Benchmark.rails("activerecord/#{db_adapter}_scope_all_with_default_scope", time: 5) do
  User.all.to_a
end
