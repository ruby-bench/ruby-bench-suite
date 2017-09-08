require "bundler/setup"
require "active_record"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name, :email
    t.integer :topic_id
    t.timestamps null: false
  end

  create_table :topics, force: true do |t|
    t.string :title
    t.timestamps null: false
  end
end

attributes = {
  name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
  email: 'foobar@email.com'
}

class Topic < ActiveRecord::Base
  has_many :users
end

class User < ActiveRecord::Base
  belongs_to :topic
end

100.times do
  User.create!(attributes)
end

users = User.first(50)

100.times do
  Topic.create!(title: 'This is a topic', users: users)
end
