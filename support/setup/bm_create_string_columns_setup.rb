require "bundler/setup"
require "active_record"
require_relative "../helpers"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    STRING_COLUMNS_COUNT.times do |i|
      t.string :"column#{i}"
    end

    t.timestamps null: false
  end
end
