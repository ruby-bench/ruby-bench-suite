require 'bundler/setup'

require 'benchmark/ips'
require 'json'
require 'ffaker'

require 'rails'
require 'action_controller/railtie'
require 'active_model'

TIME    = (ENV['BENCHMARK_TIME'] || 10).to_i

class HeavyController < ActionController::Base
  def index
    # @more_records = %w(one two three)
  end
end

class HeavyView < ActionView::Base
  # include ApplicationHelper
  # include Rails.application.routes.url_helpers
  def protect_against_forgery?
    false
  end
end

class Post
  include ActiveModel::Model

  attr_accessor :title, :from, :body

  # def title
  #   Faker::Name.name
  # end

  # def from
  #   Faker::AddressFI.city
  # end

  # def body
  #   Faker::HipsterIpsum.words(50).join(" ")
  # end
end

class User
  include ActiveModel::Model

  attr_accessor :email
  # def email
  #   Faker::Internet.email
  # end
end

def post_factory
  { title: Faker::Name.name, from: Faker::AddressFI.city, body: Faker::HipsterIpsum.words(50).join(" ") }
end

def user_factory
  { email: Faker::Internet.email }
end

def render_views
  controller = HeavyController.new
  controller.request = ActionDispatch::Request.new({})

  current = File.expand_path File.dirname(__FILE__)
  view = HeavyView.new("#{current}/form_partials", {}, controller)

  locals = {
    posts: (1..50).to_a.map { |a| Post.new(post_factory) },
    users: (1..50).to_a.map { |a| User.new(user_factory) },
  }
  view.render(template: "first", layout: "layouts/application", locals: locals)
end

# file = Tempfile.new('foo')
# file.write(render_views)
# `open #{file.path}`
# sleep 1

report = Benchmark.ips(TIME, quiet: true) do |x|
  x.report("render nested partials") do
    render_views
  end
end

stats = {
  component: "actionview/render_activemodels",
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
