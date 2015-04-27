require 'bundler/setup'

require_relative 'support/benchmark_rails.rb'

require 'rails'
require 'action_controller/railtie'
require 'active_model'

class HeavyController < ActionController::Base
  def index;end
end

class HeavyView < ActionView::Base
  def protect_against_forgery?
    false
  end
end

class Post
  include ActiveModel::Model

  attr_accessor :title, :from, :body
end

class User
  include ActiveModel::Model

  attr_accessor :email
end

def post_factory
  { title: Faker::Name.name, from: Faker::AddressFI.city, body: Faker::HipsterIpsum.words(50).join(" ") }
end

def user_factory
  { email: Faker::Internet.email }
end

current = File.expand_path File.dirname(__FILE__)
Benchmark.rails("actionview_render_activemodels", time: 10) do
  controller = HeavyController.new
  controller.request = ActionDispatch::Request.new({})

  view = HeavyView.new("#{current}/form_partials", {}, controller)

  locals = {
    posts: (1..50).to_a.map { |a| Post.new(post_factory) },
    users: (1..50).to_a.map { |a| User.new(user_factory) },
  }
  view.render(template: "first", layout: "layouts/application", locals: locals)
end
