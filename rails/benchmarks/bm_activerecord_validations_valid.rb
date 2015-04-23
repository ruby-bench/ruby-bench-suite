require_relative 'support/activerecord_validations_base.rb'
require_relative 'support/benchmark_rails.rb'

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

Benchmark.rails("activerecord/#{db_adapter}_validations_valid", time: 10) do
  unless post.valid?
    raise "should be valid"
  end
end
