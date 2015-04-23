require 'bundler/setup'
require 'rails'
require 'active_record'

require_relative 'support/benchmark_rails.rb'

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

Benchmark.rails("activerecord/#{db_adapter}_destroy", time: 10) do
  # we need to create the record in order to delete it
  user = User.create!(attributes)
  user.destroy
end
