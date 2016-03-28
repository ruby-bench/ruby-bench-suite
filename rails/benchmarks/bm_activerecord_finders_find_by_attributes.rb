require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name, :email
    t.timestamps null: false
  end
end

class User < ActiveRecord::Base; end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

1000.times do
  User.create!(attributes)
end

User.create!(name: 'kir', email: 'shatrov@me.com')

Benchmark::Rails.new("activerecord/#{db_adapter}_finders_find_by_attributes", time: 5) do |x|
  x.report('default settings') { User.find_by(email: 'shatrov@me.com') }

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    ActiveRecord::Base.connection.unprepared_statement do
      x.report('without prepared statements') { User.find_by(email: 'shatrov@me.com') }
    end
  end
end

