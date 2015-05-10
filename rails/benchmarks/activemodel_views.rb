require 'bundler/setup'
require 'action_controller/railtie'
require 'active_model'
require_relative 'support/benchmark_rails'

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
  {
    title: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    from: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
  }
end

def user_factory
  {
    email: 'test@example.com'
  }
end

current_path = File.expand_path File.dirname(__FILE__)
controller = HeavyController.new
controller.request = ActionDispatch::Request.new({})

locals = {
  posts: (1..50).to_a.map { Post.new(post_factory) },
  users: (1..50).to_a.map { User.new(user_factory) }
}

view = HeavyView.new("#{current_path}/form_partials", {}, controller)

Benchmark.rails("actionview_render_activemodels", time: 10) do
  view.render(template: "first", layout: "layouts/application", locals: locals)
end
