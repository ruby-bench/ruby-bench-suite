require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("activerecord/#{db_adapter}_new", time: 10) do
  attrs = { name: 'sam' }

  Exhibit.new
  Exhibit.new(attrs)
end
