require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("activerecord/#{db_adapter}/update", time: 10) do
  model = Exhibit.first
  if model.respond_to?(:update)
    Exhibit.first.update(name: 'bob')
  else
    Exhibit.first.update_attributes(name: 'bob')
  end
end
