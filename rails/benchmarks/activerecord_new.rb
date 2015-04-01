require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "activerecord/#{db_adapter}/new") do
  attrs = { name: 'sam' }

  Exhibit.new
  Exhibit.new(attrs)
end

puts m.to_json
