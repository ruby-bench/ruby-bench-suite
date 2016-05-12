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
  before_filter :set_post, only: [:update]

  # GET /posts/1/edit
  def edit
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update_attributes(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:id, :title, :body, :author)
  end
end

Post.create!(
  id: 1,
  title: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
  body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
  author: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
)

request = Rack::MockRequest.env_for(
  "http://localhost:3000/posts/1",
  method: 'PUT',
  input: "post%5Bauthor%5D=C&post%5Bbody%5D=B&post%5Btitle%5D=A",
).merge("CONTENT_TYPE" => "application/x-www-form-urlencoded")

Benchmark.rails("request/#{db_adapter}_scaffold_update", time: 5) { RequestHelper.perform(ScaffoldApp, request) }
