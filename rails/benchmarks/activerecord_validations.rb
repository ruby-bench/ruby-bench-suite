require 'bundler/setup'

require 'benchmark/ips'
require 'json'

require 'rails'
require 'action_controller/railtie'
require 'active_record'
require 'sqlite3'
require 'ffaker'

TIME = (ENV['BENCHMARK_TIME'] || 5).to_i

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
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

report = Benchmark.ips(TIME, quiet: true) do |x|
  x.report("validating not valid post") do
    post = Post.new({
      title: '',
      author: '',
      age: 10,
      sequence: 90,
      subdomain: 'jp',
      legacy_code: '32_leg',
      size: 'overbig'
    })

    if post.valid?
      raise "should not be valid"
    end
  end

  x.report("validating valid post") do
    post = Post.new({
      title: 'minor',
      author: 'Kir',
      age: 21,
      sequence: 90,
      subdomain: 'ru',
      legacy_code: 'letters',
      size: 'small'
    })
    post.valid?
    post.save!
    post.destroy
  end
end

stats = {
  component: 'active_record/validations',
  version: Rails.version.to_s,
  entries: report.entries.map { |e|
    {
      label: e.label,
      iterations: e.iterations,
      ips: e.ips,
      ips_sd: e.ips_sd
    }
  }
}

puts stats.to_json
