require "bundler/setup"
require "active_record"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

COUNT = 25

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    COUNT.times do |i|
      t.string :"column#{i}"
    end

    t.timestamps null: false
  end
end
