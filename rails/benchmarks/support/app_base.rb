require 'bundler/setup'

require 'rails'
require 'action_controller/railtie'
require 'active_record'
require 'sqlite3'

class NullLoger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end

class BenchmarkApp < Rails::Application
  config.secret_token = "s"*30
  config.secret_key_base = 'foo'
  config.consider_all_requests_local = false

  # simulate production
  config.cache_classes = true
  config.eager_load = true
  config.action_controller.perform_caching = true

  # otherwise deadlock occured
  config.middleware.delete "Rack::Lock"

  # to disable log files
  config.logger = NullLoger.new
  config.active_support.deprecation = :log

  config.autoflush_log = false
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :author
    t.text :body
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.text :body
    t.string :email
    t.string :author
    t.timestamps
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

BenchmarkApp.initialize!

Rails.application.routes.draw do
  resources :posts do
    resources :comments
  end
end

ActionController::Base.prepend_view_path File.expand_path("../../views", __FILE__)

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
    if defined?(ActionController::Parameters) && params.instance_of?(ActionController::Parameters)
      params.require(:post).permit(:title, :body, :author)
    else
      params[:post]
    end
  end
end

class CommentsController < ActionController::Base
  before_filter :set_post
  before_filter :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @comments = @post.comments.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = @post.comments.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @post.comments.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @post, notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @post, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @post, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    if defined?(ActionController::Parameters) && params.instance_of?(ActionController::Parameters)
      params.require(:comment).permit(:body, :author, :email)
    else
      params[:comment]
    end
  end
end

class AppBenchmark
  class FailedRequest < StandardError;end

  mattr_accessor :accept

  def self.request(method, path, query_string: "", body: {})
    env = {
      "GATEWAY_INTERFACE"=>"CGI/1.1",
      "PATH_INFO"=>path,
      "QUERY_STRING"=>query_string,
      "REMOTE_ADDR"=>"127.0.0.1",
      "REMOTE_HOST"=>"127.0.0.1",
      "REQUEST_METHOD"=>method.to_s.upcase,
      "REQUEST_URI"=>"http://localhost:3000#{path}",
      "SCRIPT_NAME"=>"",
      "SERVER_NAME"=>"localhost",
      "SERVER_PORT"=>"3000",
      "SERVER_PROTOCOL"=>"HTTP/1.1",
      "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)",
      "HTTP_HOST"=>"localhost:3000",
      "HTTP_ACCEPT_ENCODING"=>"gzip, deflate",
      "HTTP_ACCEPT"=> (self.accept.presence || "*/*"),
      "HTTP_USER_AGENT"=>"HTTPie/0.8.0",
      "rack.version"=>[1, 2],
      "rack.multithread"=>false,
      "rack.multiprocess"=>false,
      "rack.run_once"=>false,
      "rack.url_scheme"=>"http",
      "rack.input" => StringIO.new(body.to_query),
      "HTTP_VERSION"=>"HTTP/1.1",
      "REQUEST_PATH"=>path
    }
    response = BenchmarkApp.call(env)
    if response[0].to_i.in?([404, 500, 422])
      raise FailedRequest.new, "failed request: #{method.to_s.upcase} #{path} #{response[0]}"
    end
    response
  end
end
