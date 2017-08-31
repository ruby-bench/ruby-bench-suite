require "bundler/setup"
require "active_record"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.boolean :approved
    t.integer :age
    t.datetime :birthday
    t.timestamps null: false
  end

  add_index :users, :email, unique: true
end

class User < ActiveRecord::Base; end

1000.times do |i|
  User.create!({
    name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    email: "foobar#{"%03d" % i}@email.com",
    approved: false,
    age: 51,
    birthday: DateTime.now
  })
end
