require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("activerecord/#{db_adapter}/fetch", time: 10) do
  Exhibit.look Exhibit.limit(100)
  Exhibit.look Exhibit.first(100)
  Exhibit.feel Exhibit.limit(100).includes(:user)
  Exhibit.look Exhibit.limit(10000)
end
