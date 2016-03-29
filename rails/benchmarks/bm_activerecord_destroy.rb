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

Benchmark::Rails.new("activerecord/#{db_adapter}_destroy", time: 5) do |x|
  x.report('default settings') do
    # we need to create the record in order to delete it
    user = User.create!(attributes)
    user.destroy
  end

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    ActiveRecord::Base.connection.unprepared_statement do
      x.report('without prepared statements') do
        # we need to create the record in order to delete it
        user = User.create!(attributes)
        user.destroy
      end
    end
  end
end
