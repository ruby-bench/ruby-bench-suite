require_relative 'support/activerecord_base.rb'

m = Benchmark.measure do
  model = Exhibit.first
  if model.respond_to?(:update)
    Exhibit.first.update(name: 'bob')
  else
    Exhibit.first.update_attributes(name: 'bob')
  end
end

stats = {
  component: "activerecord/#{db_adapter}/update",
  version: ActiveRecord::VERSION::STRING,
  timing: m.real
}

puts stats.to_json
