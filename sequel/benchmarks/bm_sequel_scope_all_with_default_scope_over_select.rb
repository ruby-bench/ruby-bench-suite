require 'bundler/setup'
require 'sequel'
require_relative 'support/benchmark_sequel'

db_setup script: "bm_with_default_scope_setup.rb"

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

class User < Sequel::Model
  dataset_module do
    def only_admins
      where(:admin => true)
    end
  end

  set_dataset(self.only_admins)
end

Benchmark.sequel("sequel/#{db_adapter}_scope_all_with_default_scope", time: 5) do
  str = ""
  User.all.each do |user|
    str << "name: #{user.name} email: #{user.email}\n"
  end
end
