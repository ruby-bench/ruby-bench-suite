require_relative 'support/activerecord_base.rb'

m = Benchmark.measure do
  Exhibit.look Exhibit.limit(100)
  Exhibit.look Exhibit.first(100)
  Exhibit.feel Exhibit.limit(100).includes(:user)
  Exhibit.look Exhibit.limit(10000)
end

stats = {
  component: "activerecord/#{db_adapter}/fetch",
  version: ActiveRecord::VERSION::STRING,
  timing: m.real
}

puts stats.to_json
