require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_save_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

class User < ActiveRecord::Base; end

Benchmark.rails("activerecord/#{db_adapter}_save", time: 5) do
  user = User.new(attributes)

  unless user.save
    raise "should save correctly"
  end
end
