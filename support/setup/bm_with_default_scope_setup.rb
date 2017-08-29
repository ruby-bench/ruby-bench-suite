require "bundler/setup"
require "active_record"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
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

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

500.times { User.create!(attributes.merge(admin: true)) }
500.times { User.create!(attributes.merge(admin: false)) }
