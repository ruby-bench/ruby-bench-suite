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
  config.logger = NullLoger.new
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

def request(method, path, query_string: "")
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
    "rack.input" => StringIO.new,
    "HTTP_VERSION"=>"HTTP/1.1",
    "REQUEST_PATH"=>path
  }
  response = BenchmarkApp.call(env)
  if response[0].in?([404, 500])
    raise RouteNotFoundError.new, "not found #{method.to_s.upcase} #{path}"
  end
  response
end

report = Benchmark.ips(TIME, quiet: true) do |x|
  x.report("root route") do
    request(:get, "/")
  end

  x.report '3rd level nested resource #index' do
    request(:get, "/topics/1/messages/1/likes/")
  end

  x.report '3rd level nested resource #show' do
    request(:get, "/topics/1/messages/1/likes/1")
  end

  x.report 'route with inline redirect' do
    request(:get, "/listings/complicated")
  end

  x.report("match with POST") do
    request(:post, "/professionals/category/first")
  end

  x.report("match with GET") do
    request(:get, "/professionals/category/first")
  end
end

stats = {
  component: :router,
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
