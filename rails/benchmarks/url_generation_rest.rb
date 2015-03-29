require_relative 'support/url_generation_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "actionpack/url_generation/rest") do
  router = Router.new

  router.topic_path(2)
  router.edit_topic_path(2)
  router.edit_topic_message_path(1, 2)
  router.new_topic_message_path(1, 2)
  router.topic_message_path(1, 2)

  router.topic_message_like_path(1, 2, 3)
  router.edit_topic_message_like_path(1, 2, 3)
  router.new_topic_message_like_path(1, 2, 3)
end
puts m.to_json
