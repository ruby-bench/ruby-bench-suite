require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("activerecord/#{db_adapter}_create", time: 10) do
  notes = ActiveRecord::Faker::LOREM.join ' '
  fields = {
    name: ActiveRecord::Faker.name,
    notes: notes,
    created_at: Date.today
  }
  Exhibit.create(fields)
end
