require 'bundler/setup'
require 'rails'
require 'action_controller/railtie'
require 'active_record'
require_relative 'support/benchmark_rails'

class NullLogger < Logger
  def initialize(*args);end
  def add(*args, &block);end
end

class App
  def self.request(method, path, body: {})
    rack_input = StringIO.new(body.to_query)

    env = {
      "GATEWAY_INTERFACE" => "CGI/1.1",
      "PATH_INFO" => path,
      "QUERY_STRING" => "",
      "REMOTE_ADDR" => "127.0.0.1",
      "REMOTE_HOST" => "127.0.0.1",
      "REQUEST_METHOD" => method.to_s.upcase,
      "REQUEST_URI" => "http://localhost:3000#{path}",
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
      "rack.input" => rack_input,
      "CONTENT_LENGTH" => rack_input.length.to_s,
      "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
      "HTTP_VERSION" => "HTTP/1.1",
      "REQUEST_PATH" => path
    }

    status, _, body = ScaffoldAPP.call(env)
    raise "#{status} #{method.to_s.upcase} #{path}" unless [302, 200].include?(status)
    body.close if body.respond_to?(:close)
  end
end

class ScaffoldAPP < Rails::Application
  config.secret_token = "s"*30
  config.secret_key_base = 'foo'

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable log files
  config.logger = NullLogger.new
  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # otherwise deadlock occurs
  config.middleware.delete "Rack::Lock"
end

ScaffoldAPP.initialize!

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

class Post < ActiveRecord::Base; end

Rails.application.routes.draw do
  resources :posts
end

ActionController::Base.prepend_view_path File.expand_path("../views", __FILE__)

class PostsController < ActionController::Base
  before_filter :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:title, :body, :author)
  end
end

Post.create!(
  title: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
  body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
  author: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
)

post_params =  {
  post: {
    title: 'A',
    body: 'B',
    author: 'C'
  }
}

Benchmark.rails("scaffold_app", time: 1) do
  App.request(:get, "/posts")
  App.request(:get, "/posts/1")
  App.request(:get, "/posts/new")
  App.request(:post, "/posts", body: post_params)
  App.request(:put, "/posts/1", body: post_params)
  App.request(:delete, "/posts/1")
end
