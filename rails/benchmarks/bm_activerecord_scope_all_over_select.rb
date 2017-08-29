require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_scope_all_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

Benchmark.rails("activerecord/#{db_adapter}_scope_all_over_select", time: 5) do
  str = ""
  User.all.each do |user|
    str << "name: #{user.name} email: #{user.email} approved: #{user.approved} age: #{user.age} birthday: #{user.birthday}\n"
  end
end
