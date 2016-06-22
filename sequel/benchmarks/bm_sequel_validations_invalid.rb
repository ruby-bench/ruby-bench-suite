require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

DB.create_table(:posts) do
  primary_key :id
  String :title, size: 255
  String :author, size: 255
  String :body, text: true
  Fixnum :sequence
  Fixnum :age
  String :legacy_code, size: 255
  String :size, size: 255
end

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
  title: '',
  author: '',
  age: 10,
  sequence: 90,
  legacy_code: '32_leg',
  size: 'overbig'
})

Benchmark.sequel("sequel/#{db_adapter}_validations_invalid", time: 5) do
  if post.valid?
    raise "should not be valid"
  end
end
