require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

db_setup script: "bm_discourse_setup.rb"

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

class User < ActiveRecord::Base
  has_many :topic_users
  has_many :category_users
  has_many :topics
end

class Topic < ActiveRecord::Base
  has_many :topic_users
  has_many :categories
  belongs_to :user
  belongs_to :category
  scope :listable_topics, -> { where('topics.archetype <> ?', 'private_message') }
end

class TopicUser < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
end

class Category < ActiveRecord::Base
  has_many :category_users
  has_many :topics
  belongs_to :topic
end

class CategoryUser < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
end

user = User.first

Benchmark.rails("active_record/#{db_adapter}_discourse", time: 5) do
  str = ""
  Topic
    .unscoped
    .includes(:user, :category)
    .references(:user, :category)
    .joins("LEFT OUTER JOIN topic_users AS tu ON (topics.id = tu.topic_id AND tu.user_id = #{user.id})")
    .listable_topics
    .where('COALESCE(categories.topic_id, 0) <> topics.id')
    .where('topics.deleted_at IS NULL')
    .where(
      "NOT EXISTS (
           SELECT 1 FROM category_users cu
             WHERE cu.user_id = :user_id
             AND cu.category_id = topics.category_id
             AND cu.notification_level = :muted
             AND cu.category_id <> :category_id
             AND (tu.notification_level IS NULL OR tu.notification_level < :tracking)
        )",
        user_id: user.id, muted: 0, tracking: 2, category_id: -1
    ).where("pinned_globally AND pinned_at IS NOT NULL AND (topics.pinned_at > tu.cleared_pinned_at OR tu.cleared_pinned_at IS NULL)")
    .order("topics.bumped_at DESC")
    .limit(30)
    .each do |topic|
      str << "id: #{topic.id} title: #{topic.title} created_at: #{topic.created_at.iso8601} user: #{topic.user.username}\n"
    end
end
