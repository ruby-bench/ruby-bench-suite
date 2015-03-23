require_relative 'support/activerecord_validations_base.rb'

m = Benchmark.measure do
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

stats = {
  component: 'active_record/validations/valid',
  version: Rails.version.to_s,
  timing: m.real
}

puts stats.to_json
