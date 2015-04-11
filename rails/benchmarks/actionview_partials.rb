require 'bundler/setup'

require 'ffaker'

require 'rails'
require 'action_controller/railtie'

require_relative 'support/benchmark_rails.rb'

class HeavyController < ActionController::Base
  def index
  end
end

class HeavyView < ActionView::Base
end

Post = Struct.new(:id) do
  def title
    Faker::Name.name
  end

  def from
    Faker::AddressFI.city
  end

  def body
    Faker::HipsterIpsum.words(50).join(" ")
  end
end

User = Struct.new(:id) do
  def email
    Faker::Internet.email
  end
end

def render_views
  controller = HeavyController.new
  controller.request = ActionDispatch::Request.new({})

  current = File.expand_path File.dirname(__FILE__)
  view = HeavyView.new("#{current}/partials", {}, controller)

  locals = {
    records: 3,
    posts: (1..50).to_a.map { |a| Post.new(a) },
    users: (1..50).to_a.map { |a| User.new(a) },
  }
  view.render(template: "first", layout: "layouts/application", locals: locals)
end

Benchmark.rails("actionview_render_partials", time: 10) do
  render_views
end
