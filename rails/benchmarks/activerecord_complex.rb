require 'bundler/setup'
require 'json'

require 'rails'
require 'action_controller/railtie'
require 'active_record'
require 'sqlite3'
require 'ffaker'

require_relative 'support/benchmark_rails.rb'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :author
    t.text :body
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.text :body
    t.string :email
    t.string :author
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

5.times do
  post = Post.create!(title: Faker::Name.name, body: Faker::HipsterIpsum.words(50).join(" "))
  2.times do
    post.comments.create(email: Faker::Internet.email, body: Faker::HipsterIpsum.words(50).join(" "), author: Faker::Name.name)
  end
end

m = Benchmark.rails(100, "activerecord/#{ENV['DATABASE_URL'].split(":")[0]}/complex") do
  Post.all

  2.times do
    Post.create!(title: Faker::Food.herb_or_spice, body: Faker::HipsterIpsum.words(50).join(" "), author: Faker::Name.name)
  end

  Post.all.each do |post|
    pos = Post.find(post.id)
    pos.comments.all

    pos.comments.create!(
      body: Faker::HipsterIpsum.words(50).join(" "),
      email: Faker::Internet.email,
      author: Faker::Name.name)

    Post.find(post.id)
    Post.find(post.id).comments.all
    Post.find(post.id).destroy
  end
end

puts m.to_json
