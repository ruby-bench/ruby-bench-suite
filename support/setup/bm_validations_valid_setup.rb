require "bundler/setup"
require "active_record"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :author
    t.text :body
    t.integer :sequence
    t.integer :age
    t.string :subdomain
    t.string :legacy_code
    t.string :size
  end
end

class Post < ActiveRecord::Base; end

Post.create!({
  title: 'RubyBench',
  author: 'RubyBench',
  age: 21,
  sequence: 90,
  subdomain: 'ru',
  legacy_code: 'letters',
  size: 'small'
})
