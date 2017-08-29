require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_scope_all_setup.rb"

Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model
  plugin :timestamps, update_on_create: true
end

Benchmark.sequel("sequel/#{db_adapter}_scope_all", time: 5) do
  str = ""
  User.all.each do |user|
    str << "name: #{user.name} email: #{user.email}\n"
  end
end
