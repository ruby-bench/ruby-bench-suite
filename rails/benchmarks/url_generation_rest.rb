require_relative 'support/url_generation_base.rb'
require_relative 'support/benchmark_rails.rb'

Benchmark.rails("actionpack/url_generation/rest", time: 10) do
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
