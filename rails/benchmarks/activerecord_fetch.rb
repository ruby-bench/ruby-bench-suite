require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "activerecord/#{db_adapter}/fetch") do
  Exhibit.look Exhibit.limit(100)
  Exhibit.look Exhibit.first(100)
  Exhibit.feel Exhibit.limit(100).includes(:user)
  Exhibit.look Exhibit.limit(10000)
end

puts m.to_json
