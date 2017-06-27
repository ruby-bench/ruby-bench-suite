require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
 # TODO: define required tables
end

# TODO: create models and records

Benchmark.rails("active_record/#{db_adapter}_scope_all", time: 5) do
  Topic
    .unscoped
    .joins("LEFT OUTER JOIN topic_users AS tu ON (topics.id = tu.topic_id AND tu.user_id = #{user.id})")
    .references("tu")
    .order("topics.bumped_at DESC")
    .listable_topics # scope :listable_topics, -> { where('topics.archetype <> ?', Archetype.private_message) }
    .where('COALESCE(categories.topic_id, 0) <> topics.id')
    .where('topics.id IN (SELECT topic_id FROM topic_users WHERE user_id = ? AND notification_level = ?)', user.id, level)
    .where('topics.deleted_at IS NULL')
    .where('COALESCE(tu.notification_level,1) > :muted', muted: TopicUser.notification_levels[:muted])
    .references("cu")
    .where(
      "NOT EXISTS (
         SELECT 1 FROM category_users cu
           WHERE cu.user_id = :user_id
           AND cu.category_id = topics.category_id
           AND cu.notification_level = :muted
           AND cu.category_id <> :category_id
           AND (tu.notification_level IS NULL OR tu.notification_level < :tracking)
      )",
      user_id: user.id, muted: muted, tracking: tracking, category_id: -1
    ).where("pinned_globally AND pinned_at IS NOT NULL AND (topics.pinned_at > tu.cleared_pinned_at OR tu.cleared_pinned_at IS NULL)")
    .limit(30)
end
