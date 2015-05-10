require 'bundler/setup'
require 'rails'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

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

class Post < ActiveRecord::Base
  validates :title, presence: true, confirmation: true
  validates :sequence, uniqueness: true
  validates :age, numericality: { greater_than: 18, less_than: 80 }
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end

Post.create!({
  title: 'RubyBench',
  author: 'RubyBench',
  age: 21,
  sequence: 90,
  subdomain: 'ru',
  legacy_code: 'letters',
  size: 'small'
})

post = Post.new({
  title: 'RubyBench',
  author: 'RubyBench',
  age: 21,
  sequence: 50,
  subdomain: 'ru',
  legacy_code: 'letters',
  size: 'small'
})

Benchmark.rails("activerecord/activerecord_validations_valid", time: 10) do
  unless post.valid?
    raise "should be valid"
  end
end
