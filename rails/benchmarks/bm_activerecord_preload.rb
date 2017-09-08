require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_preload_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

class Topic < ActiveRecord::Base
  has_many :users
end

class User < ActiveRecord::Base
  belongs_to :topic
end

Benchmark.rails("activerecord/#{db_adapter}_preload", time: 5) do
  User.includes(:topic).all.to_a
end
