require 'bundler/setup'

require 'active_record'
require 'json'

RECORDS = (ENV['BENCHMARK_RECORDS'] || 1000).to_i

class User < ActiveRecord::Base
  has_many :exhibits
end

class Exhibit < ActiveRecord::Base

  belongs_to :user

  def look; attributes end
  def feel; look; user.name end

  def self.with_name
    where("name IS NOT NULL")
  end

  def self.with_notes
    where("notes IS NOT NULL")
  end

  def self.look(exhibits) exhibits.each(&:look) end
  def self.feel(exhibits) exhibits.each(&:feel) end
end


module ActiveRecord
  class Faker
    LOREM = %Q{Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse non aliquet diam. Curabitur vel urna metus, quis malesuada elit.
     Integer consequat tincidunt felis. Etiam non erat dolor. Vivamus imperdiet nibh sit amet diam eleifend id posuere diam malesuada. Mauris at accumsan sem.
     Donec id lorem neque. Fusce erat lorem, ornare eu congue vitae, malesuada quis neque. Maecenas vel urna a velit pretium fermentum. Donec tortor enim,
     tempor venenatis egestas a, tempor sed ipsum. Ut arcu justo, faucibus non imperdiet ac, interdum at diam. Pellentesque ipsum enim, venenatis ut iaculis vitae,
     varius vitae sem. Sed rutrum quam ac elit euismod bibendum. Donec ultricies ultricies magna, at lacinia libero mollis aliquam. Sed ac arcu in tortor elementum
     tincidunt vel interdum sem. Curabitur eget erat arcu. Praesent eget eros leo. Nam magna enim, sollicitudin vehicula scelerisque in, vulputate ut libero.
     Praesent varius tincidunt commodo}.split

    def self.name
      LOREM.grep(/^\w*$/).sort_by { rand }.first(2).join ' '
    end

    def self.email
      LOREM.grep(/^\w*$/).sort_by { rand }.first(2).join('@') + ".com"
    end
  end

end

def db_adapter
  ENV['DATABASE_URL'].split(":")[0]
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name, :email
    t.timestamps null: false
  end

  create_table :exhibits, force: true do |t|
    t.belongs_to :user
    t.string :name
    t.text :notes
    t.timestamps null: false
  end
end

notes = ActiveRecord::Faker::LOREM.join(' ')
today = Date.today

RECORDS.times do |record|
  user = User.create!(
    created_at: today,
    name: ActiveRecord::Faker.name,
    email: ActiveRecord::Faker.email
  )

  Exhibit.create!(
    created_at: today,
    name: ActiveRecord::Faker.name,
    user: user,
    notes: notes
  )
end
