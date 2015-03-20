require_relative 'support/activerecord_base.rb'

m = Benchmark.measure do
  Exhibit.limit(10).with_name.with_notes
end

stats = {
  component: "activerecord/#{db_adapter}/scope",
  version: ActiveRecord::VERSION::STRING,
  timing: m.real
}

puts stats.to_json
