require_relative 'support/activerecord_validations_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("active_record/validations/valid", time: 10) do
  post = Post.new({
    title: 'minor',
    author: 'Kir',
    age: 21,
    sequence: 90,
    subdomain: 'ru',
    legacy_code: 'letters',
    size: 'small'
  })
  post.valid?
  post.save!
  post.destroy
end
