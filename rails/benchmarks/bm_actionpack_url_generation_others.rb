require_relative 'support/url_generation_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("actionpack_url_generation_others", time: 10) do
  router = Router.new

  router.listing_redirect_path(:any)
  router.residential_path(id: 2, addressing_slug: 'brooklyn')
  router.by_category_professionals_path(2)
end
