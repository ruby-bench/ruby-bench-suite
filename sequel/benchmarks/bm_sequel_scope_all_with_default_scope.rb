require 'bundler/setup'
require 'sequel'

require_relative 'support/benchmark_sequel'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

DB.create_table!(:users) do
  primary_key :id
  String :name, size: 255
  String :email, size: 255
  TrueClass :admin, null: false
  DateTime :created_at, null: true
  DateTime :updated_at, null: true
end

class User < Sequel::Model
  dataset_module do
    def only_admins
      where(:admin => true)
    end
  end

  set_dataset(self.only_admins)
end

admin = true

1000.times do
  attributes = {
    name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    email: "foobar@email.com",
    admin: admin
  }

  User.create(attributes)

  admin = !admin
end

Benchmark.sequel("sequel/#{db_adapter}_scope_all_with_default_scope", time: 5) do
  str = ""
  User.all.each do |user|
    str << "name: #{user.name} email: #{user.email}\n"
  end
end
