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

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

class User < ActiveRecord::Base; end

Benchmark::Rails.new("activerecord/#{db_adapter}_save", time: 5) do |x|
  x.report('default settings') do
    user = User.new(attributes)

    unless user.save
      raise "should save correctly"
    end
  end

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    ActiveRecord::Base.connection.unprepared_statement do
      x.report('without prepared statements') do
        user = User.new(attributes)

        unless user.save
          raise "should save correctly"
        end
      end
    end
  end
end
