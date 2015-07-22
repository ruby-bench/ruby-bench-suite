require 'bundler/setup'
require 'rails'
require 'action_controller/railtie'
require 'active_record'
require_relative 'support/benchmark_rails'

class App
  ENV = {
    "GATEWAY_INTERFACE" => "CGI/1.1",
    "PATH_INFO" => '/posts/new',
    "QUERY_STRING" => "",
    "REMOTE_ADDR" => "127.0.0.1",
    "REMOTE_HOST" => "127.0.0.1",
    "REQUEST_METHOD" => 'GET',
    "REQUEST_URI" => "http://localhost:3000/posts/new",
    "SCRIPT_NAME" => "",
    "SERVER_NAME" => "localhost",
    "SERVER_PORT" => "3000",
    "SERVER_PROTOCOL" => "HTTP/1.1",
    "SERVER_SOFTWARE" => "WEBrick/1.3.1 (Ruby/2.2.2/2014-05-08)",
    "HTTP_HOST" => "localhost:3000",
    "HTTP_ACCEPT" =>  "*/*",
    "HTTP_USER_AGENT" => "HTTPie/0.8.0",
    "rack.version" => [1, 2],
    "rack.multithread" => false,
    "rack.multiprocess" => false,
    "rack.run_once" => false,
    "rack.url_scheme" => "http",
    "rack.errors" => StringIO.new,
    "rack.input" => StringIO.new,
    "HTTP_VERSION" => "HTTP/1.1",
    "REQUEST_PATH" => "/posts/new"
  }

  def self.request
    _, _, body = ScaffoldApp.call(ENV)
    body.close if body.respond_to?(:close)
  end
end

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

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
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

Benchmark.rails("request/#{db_adapter}_scaffold_new", time: 5) { App.request }
