require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "activerecord/#{db_adapter}/update") do
  model = Exhibit.first
  if model.respond_to?(:update)
    Exhibit.first.update(name: 'bob')
  else
    Exhibit.first.update_attributes(name: 'bob')
  end
end

puts m.to_json
