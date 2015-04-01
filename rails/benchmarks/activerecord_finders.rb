require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

User.create!(name: 'kir', email: 'shatrov@me.com')

m = Benchmark.rails(100, "activerecord/#{db_adapter}/finders") do
  User.first
  User.find(1)
  User.find_by(email: 'shatrov@me.com')
  User.find_by(name: 'kir')
end

puts m.to_json
