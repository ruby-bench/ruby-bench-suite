require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_destroy_setup.rb"

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model
  self.raise_on_save_failure = true
  plugin :timestamps, update_on_create: true
end

attributes = {
  name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  email: "foobar@email.com"
}

Benchmark.sequel("sequel/#{db_adapter}_destroy", time: 5) do
  # we need to create the record in order to delete it
  user = User.create(attributes)
  user.destroy
end
