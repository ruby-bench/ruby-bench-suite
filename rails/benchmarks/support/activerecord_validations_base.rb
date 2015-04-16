require 'bundler/setup'

require 'rails'
require 'action_controller/railtie'
require 'active_record'
require 'sqlite3'
require 'ffaker'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :author
    t.text :body
    t.integer :sequence
    t.integer :age
    t.string :subdomain
    t.string :legacy_code
    t.string :size
  end
end

class Post < ActiveRecord::Base
  attr_accessor :title_confirmation

  validates :title, presence: true, confirmation: true
  validates :sequence, uniqueness: true

  validates :age, numericality: { greater_than: 18, less_than: 80 }

  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
