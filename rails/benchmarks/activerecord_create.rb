require_relative 'support/activerecord_base.rb'

m = Benchmark.measure do
  notes = ActiveRecord::Faker::LOREM.join ' '
  10.times do
    fields = {
      name: ActiveRecord::Faker.name,
      notes: notes,
      created_at: Date.today
    }
    Exhibit.create(fields)
  end
end

stats = {
  component: "activerecord/#{db_adapter}/create",
  version: ActiveRecord::VERSION::STRING,
  timing: m.real
}

puts stats.to_json
