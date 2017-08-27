require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_destroy_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

Benchmark.rails("activerecord/#{db_adapter}_destroy", time: 5) do
  # we need to create the record in order to delete it
  user = User.create!(attributes)
  user.destroy
end
