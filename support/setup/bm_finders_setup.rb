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
end

class User < ActiveRecord::Base; end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com",
  approved: false,
  age: 51,
  birthday: DateTime.now
}

1000.times do
  User.create!(attributes)
end

User.create!(
  name: 'kir', 
  email: 'shatrov@me.com', 
  approved: true,
  birthday: DateTime.now
)
