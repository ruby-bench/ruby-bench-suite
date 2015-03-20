require_relative 'support/activerecord_base.rb'

User.create!(name: 'kir', email: 'shatrov@me.com')

m = Benchmark.measure do
  User.first
  User.find(1)
  User.find_by(email: 'shatrov@me.com')
  User.find_by(name: 'kir')
end

stats = {
  component: "activerecord/#{db_adapter}/finders",
  version: ActiveRecord::VERSION::STRING,
  timing: m.real
}

puts stats.to_json
