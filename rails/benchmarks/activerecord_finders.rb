require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

User.create!(name: 'kir', email: 'shatrov@me.com')

Benchmark.rails("activerecord/#{db_adapter}/finders", time: 10) do
  User.first
  User.find(1)
  User.find_by(email: 'shatrov@me.com')
  User.find_by(name: 'kir')
end
