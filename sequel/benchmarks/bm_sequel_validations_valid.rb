require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_validations_valid_setup.rb"

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

class Post < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence :title
    validates_unique :sequence
    validates_numeric :age, numericality: { greater_than: 18, less_than: 80 }
    validates_format /\A[a-zA-Z]+\z/, :legacy_code, message: "only allows letters"
    validates_includes %w(small medium large), :size, message: "%{value} is not a valid size"
  end
end

post = Post.new({
  title: 'RubyBench',
  author: 'RubyBench',
  age: 21,
  sequence: 90,
  legacy_code: 'letters',
  size: 'small'
})

Benchmark.sequel("sequel/#{db_adapter}_validations_valid", time: 5) do
  if post.valid?
    raise "should be valid"
  end
end
