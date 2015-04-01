require_relative 'support/url_generation_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "actionpack/url_generation/others") do
  router = Router.new

  router.listing_redirect_path(:any)
  router.residential_path(id: 2, addressing_slug: 'brooklyn')
  router.by_category_professionals_path(2)
end
puts m.to_json
