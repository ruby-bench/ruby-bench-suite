require_relative 'support/activerecord_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("activerecord/#{db_adapter}_scope", time: 10) do
  Exhibit.limit(10).with_name.with_notes
end
