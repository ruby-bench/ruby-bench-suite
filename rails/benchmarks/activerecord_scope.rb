require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "activerecord/#{db_adapter}/scope") do
  Exhibit.limit(10).with_name.with_notes
end

puts m.to_json
