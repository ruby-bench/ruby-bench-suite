require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_scope_all_setup.rb"

Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model; end

Benchmark.sequel("sequel/#{db_adapter}_scope_all_over_select", time: 5) do
  str = ""
  User.all.each do |user|
    str << "name: #{user.name} email: #{user.email} approved: #{user.approved} age: #{user.age} birthday: #{user.birthday}\n"
  end
end
