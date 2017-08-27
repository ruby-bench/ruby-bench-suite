require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_validations_invalid_setup.rb"

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
  title: '',
  author: '',
  age: 10,
  sequence: 90,
  subdomain: 'jp',
  legacy_code: '32_leg',
  size: 'overbig'
})

Benchmark.rails("activerecord/#{db_adapter}_validations_invalid", time: 5) do
  if post.valid?
    raise "should not be valid"
  end
end
