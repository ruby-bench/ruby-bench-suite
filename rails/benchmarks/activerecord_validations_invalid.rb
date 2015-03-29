require_relative 'support/activerecord_validations_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "active_record/validations/invalid") do
  post = Post.new({
    title: '',
    author: '',
    age: 10,
    sequence: 90,
    subdomain: 'jp',
    legacy_code: '32_leg',
    size: 'overbig'
  })

  if post.valid?
    raise "should not be valid"
  end
end
puts m.to_json
