require 'bundler/setup'
require 'rails'
require 'action_controller/railtie'
require 'active_record'
require_relative 'support/benchmark_rails'
require_relative 'support/request_helper'

class ScaffoldApp < Rails::Application
  config.secret_token = "s"*30
  config.secret_key_base = 'foo'
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.log_level = :debug
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  # otherwise deadlock occurs
  config.middleware.delete "Rack::Lock"
end

ScaffoldApp.initialize!

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :author
    t.text :body
    t.timestamps
  end
end

Rails.application.routes.draw do
  resources :posts
end

class Post < ActiveRecord::Base; end

ActionController::Base.prepend_view_path File.expand_path("../views", __FILE__)

class PostsController < ActionController::Base
  # GET /posts/new
  def new
    @post = Post.new
  end
end

request = Rack::MockRequest.env_for(
  "http://localhost:3000/posts/new",
  method: 'GET',
)

Benchmark.rails("request/#{db_adapter}_scaffold_new", time: 5) { RequestHelper.perform(ScaffoldApp, request) }
