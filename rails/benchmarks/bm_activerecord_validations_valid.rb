require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_validations_valid_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

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

post = Post.new({
  title: 'RubyBench',
  author: 'RubyBench',
  age: 21,
  sequence: 50,
  subdomain: 'ru',
  legacy_code: 'letters',
  size: 'small'
})

Benchmark.rails("activerecord/#{db_adapter}_validations_valid", time: 5) do
  unless post.valid?
    raise "should be valid"
  end
end
