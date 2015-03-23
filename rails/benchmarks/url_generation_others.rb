require_relative 'support/url_generation_base.rb'

m = Benchmark.measure do
  router = Router.new

  router.listing_redirect_path(:any)
  router.residential_path(id: 2, addressing_slug: 'brooklyn')
  router.by_category_professionals_path(2)
end

stats = {
  component: 'actionpack/url_generation',
  version: Rails.version.to_s,
  timing: m.real
}

puts stats.to_json
