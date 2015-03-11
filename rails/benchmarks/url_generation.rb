require 'bundler/setup'

require 'benchmark/ips'
require 'json'

require 'rails'
require 'action_controller/railtie'

TIME    = (ENV['BENCHMARK_TIME'] || 5).to_i

class NullLoger < Logger
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
  config.logger = NullLoger.new
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

report = Benchmark.ips(TIME, quiet: true) do |x|
  router = Router.new

  x.report("redirect route") do
    router.listing_redirect_path(:any)
  end

  x.report("constraints & matched routes") do
    router.residential_path(id: 2, addressing_slug: 'brooklyn')
    router.by_category_professionals_path(2)
  end

  x.report("url_for") do
    router.url_for(controller: 'prices', action: 'info')
    router.url_for(controller: 'coupons', action: 'some')
    router.url_for(controller: 'professionals', action: 'index')
  end

  x.report("REST routes") do
    router.topic_path(2)
    router.edit_topic_path(2)
    router.edit_topic_message_path(1, 2)
    router.new_topic_message_path(1, 2)
    router.topic_message_path(1, 2)

    router.topic_message_like_path(1, 2, 3)
    router.edit_topic_message_like_path(1, 2, 3)
    router.new_topic_message_like_path(1, 2, 3)
  end
end

stats = {
  component: 'actionpack/url_generation',
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
