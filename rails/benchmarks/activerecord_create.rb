require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails(1000, "activerecord/#{db_adapter}/create") do
  notes = ActiveRecord::Faker::LOREM.join ' '
  fields = {
    name: ActiveRecord::Faker.name,
    notes: notes,
    created_at: Date.today
  }
  Exhibit.create(fields)
end
