require_relative 'support/url_generation_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("actionpack_url_generation_url_for", time: 10) do
  router = Router.new

  router.url_for(controller: 'prices', action: 'info')
  router.url_for(controller: 'coupons', action: 'some')
  router.url_for(controller: 'professionals', action: 'index')
end
