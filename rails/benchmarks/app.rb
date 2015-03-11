require 'bundler/setup'

require 'benchmark/ips'
require 'json'
require 'stackprof'

require 'rails'
require 'action_controller/railtie'
require 'active_record'
require 'sqlite3'
require 'ffaker'

TIME = (ENV['BENCHMARK_TIME'] || 5).to_i

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

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :author
    t.text :body
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.text :body
    t.string :email
    t.string :author
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

# 5.times do
#   post = Post.create!(title: Faker::Name.name, body: Faker::HipsterIpsum.words(50).join(" "))
#   2.times do
#     post.comments.create(email: Faker::Internet.email, body: Faker::HipsterIpsum.words(50).join(" "), author: Faker::Name.name)
#   end
# end

BenchmarkApp.initialize!

Rails.application.routes.draw do
  resources :posts do
    resources :comments
  end
end

ActionController::Base.prepend_view_path File.expand_path("../views", __FILE__)

class PostsController < ActionController::Base
  before_filter :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = []
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

class RouteNotFoundError < StandardError;end

def request(method, path, query_string: "", body: {})
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
    "HTTP_ACCEPT"=>"*/*",
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
  if response[0].in?([404, 500])
    raise RouteNotFoundError.new, "not found #{method.to_s.upcase} #{path}"
  end
  response
end


# StackProf.run(mode: :cpu, out: "/tmp/stackprof-app-#{Rails.version.to_s}.dump") do
  report = Benchmark.ips(TIME, quiet: true) do |x|
    x.report("app with comments and posts") do
      request(:get, "/posts")
      2.times do
        request(:get, "/posts/new")
        request(:post, "/posts", body: { post: { title: Faker::Food.herb_or_spice, body: Faker::HipsterIpsum.words(50).join(" "), author: Faker::Name.name }})
      end

      Post.all.each do |post|
        post_path = "/posts/#{post.id}"
        request(:get, post_path)
        request(:post, "#{post_path}/comments", body: {
          comment: {
            body: Faker::HipsterIpsum.words(50).join(" "),
            email: Faker::Internet.email,
            author: Faker::Name.name
          }
        })
        if Comment.count.zero?
          raise "comment not inserted"
        end

        request(:get, post_path)
        request(:delete, post_path)
        begin
          request(:get, post_path)
        rescue RouteNotFoundError
        end
      end
    end
  end
# end

stats = {
  component: :app,
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
