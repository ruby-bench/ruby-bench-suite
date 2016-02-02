require 'bundler/setup'

require 'rails'
require 'action_controller/railtie'

require_relative 'support/benchmark_rails.rb'

class NullLogger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end

class BenchmarkApp < Rails::Application
  routes.append do
    namespace :editor do
      resources :professionals
      resource :message
    end

    scope path: '/prices' do
      get 'info' => 'prices#info'
    end

    scope '/coupon' do
      get 'some' => 'coupons#some'
    end

    root to: "home#index"

    resources :topics do
      resources :messages do
        resources :likes
      end
    end

    resources :professionals, only: [:index] do
      collection do
        match 'category/:specialization_id', to: 'professionals#by_category', as: 'by_category', via: [:get, :post]
      end
    end

    get "/listings/:any" => redirect("/properties/%{any}")

    get 'system/*path', to: proc {|env| [404, {}, []] }
    constraints id: /\d+(.*)/ do
      get '/zagorodnaya/*addressing_slug/:id',
        to: 'developments#show',
        as: :residential_seo
    end
  end
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
  config.logger = NullLogger.new
  config.active_support.deprecation = :log
end

class ProfessionalsController < ActionController::Base
  def index
    render text: "Hello!"
  end

  def by_category
    render text: "Hello!"
  end
end

class HomeController < ActionController::Base
  def index
    render text: "Hello!"
  end
end

class LikesController < ActionController::Base
  def index
    render text: "likes index"
  end

  def show
    render text: "likes show"
  end
end

BenchmarkApp.initialize!

class RouteNotFoundError < StandardError;end

def request(method, path)
  response = Rack::MockRequest.new(BenchmarkApp).send(method, path)
  if response.status.in?([404, 500])
    raise RouteNotFoundError.new, "not found #{method.to_s.upcase} #{path}"
  end
  response
end

Benchmark.rails("actionpack_router", time: 10) do
  request(:get, "/")
  request(:get, "/topics/1/messages/1/likes/")

  request(:get, "/topics/1/messages/1/likes/1")

  request(:get, "/listings/complicated")
  request(:post, "/professionals/category/first")
  request(:get, "/professionals/category/first")
end
