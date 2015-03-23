require_relative 'support/activerecord_base.rb'

m = Benchmark.measure do
  attrs = { name: 'sam' }

  Exhibit.new
  Exhibit.new(attrs)
end

stats = {
  component: "activerecord/#{db_adapter}/new",
  version: ActiveRecord::VERSION::STRING,
  timing: m.real
}

puts stats.to_json
