require_relative 'support/activerecord_validations_base.rb'

m = Benchmark.measure do
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

stats = {
  component: 'active_record/validations/invalid',
  version: Rails.version.to_s,
  timing: m.real
}

puts stats.to_json
