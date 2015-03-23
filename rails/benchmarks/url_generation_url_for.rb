require_relative 'support/url_generation_base.rb'

m = Benchmark.measure do
  router = Router.new
  
  router.url_for(controller: 'prices', action: 'info')
  router.url_for(controller: 'coupons', action: 'some')
  router.url_for(controller: 'professionals', action: 'index')
end

stats = {
  component: 'actionpack/url_generation',
  version: Rails.version.to_s,
  timing: m.real
}

puts stats.to_json
