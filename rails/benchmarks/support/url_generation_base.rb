require 'bundler/setup'

require 'rails'
require 'action_controller/railtie'

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
        match 'category/:specialization_id', to: 'professionals#by_category', as: :by_category, via: [:get, :post]
      end
    end

    get "/listings/:any" => redirect("/properties/%{any}"), as: :listing_redirect

    constraints id: /\d+(.*)/ do
      get '/residential/*addressing_slug/:id',
        to: 'residential_listings#show',
        as: :residential
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

BenchmarkApp.initialize!

class Router
  include BenchmarkApp.routes.url_helpers

  def default_url_options
    {
      host: 'railsperf.io'
    }
  end
end
