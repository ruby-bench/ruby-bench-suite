require 'bundler/setup'

require 'json'
require 'ffaker'

require 'rails'
require 'action_controller/railtie'

class HeavyController < ActionController::Base
  def index
    # @more_records = %w(one two three)
  end
end

class HeavyView < ActionView::Base
  # include ApplicationHelper
  # include Rails.application.routes.url_helpers
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

m = Benchmark.measure do |x|
  render_views
end

stats = {
  component: "actionview/render_partials",
  version: Rails.version.to_s,
  timings: m.real
}

puts stats.to_json
