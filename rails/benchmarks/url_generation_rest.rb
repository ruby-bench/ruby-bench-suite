require_relative 'support/url_generation_base.rb'

m = Benchmark.measure do
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

stats = {
  component: 'actionpack/url_generation',
  version: Rails.version.to_s,
  timing: m.real
}

puts stats.to_json
