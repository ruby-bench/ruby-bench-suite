require_relative 'support/url_generation_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "actionpack/url_generation/url_for") do
  router = Router.new

  router.url_for(controller: 'prices', action: 'info')
  router.url_for(controller: 'coupons', action: 'some')
  router.url_for(controller: 'professionals', action: 'index')
end

puts m.to_json
