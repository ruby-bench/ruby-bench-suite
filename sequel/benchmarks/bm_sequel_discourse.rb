require "bundler/setup"
require "sequel"

require_relative "support/benchmark_sequel"

db_setup script: "bm_discourse_setup.rb"

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))

class User < Sequel::Model
  one_to_many :topic_users
  one_to_many :category_users
  one_to_many :topics
end

class Topic < Sequel::Model
  one_to_many :topic_users
  one_to_many :categories
  many_to_one :user
  many_to_one :category

  dataset_module do
    def listable_topics
      where(Sequel.lit("topics.archetype <> ?", "private_message"))
    end
  end
end

class TopicUser < Sequel::Model
  many_to_one :topic
  many_to_one :user
end

class Category < Sequel::Model
  one_to_many :category_users
  one_to_many :topics
  many_to_one :topic
end

class CategoryUser < Sequel::Model
  many_to_one :category
  many_to_one :user
end

user = User.first

Benchmark.sequel("sequel/#{db_adapter}_discourse", time: 5) do
  str = ""
  Topic
    .unfiltered
    .eager_graph(Sequel.as(:category, :categories))
    .eager(:user)
    .left_outer_join(Sequel.lit("topic_users AS tu ON (topics.id = tu.topic_id AND tu.user_id = #{user.id})"))
    .listable_topics
    .where(Sequel.lit("COALESCE(categories.topic_id, 0) <> topics.id"))
    .where(Sequel.lit("topics.deleted_at IS NULL"))
    .where(Sequel.lit(
      "NOT EXISTS (
        SELECT 1 FROM category_users cu
          WHERE cu.user_id = :user_id
          AND cu.category_id = topics.category_id
          AND cu.notification_level = :muted
          AND cu.category_id <> :category_id
          AND (tu.notification_level IS NULL OR tu.notification_level < :tracking)
      )",
      user_id: user.id, muted: 0, tracking: 2, category_id: -1)
    ).where(
      Sequel.lit(
        "pinned_globally AND
          pinned_at IS NOT NULL AND
          (topics.pinned_at > tu.cleared_pinned_at OR tu.cleared_pinned_at IS NULL)"
      )
    ).order(Sequel.lit("topics.bumped_at DESC"))
    .limit(30)
    .all
    .each do |topic|
      str << "id: #{topic.id} title: #{topic.title} created_at: #{topic.created_at.iso8601} user: #{topic.user.username}\n"
    end
end
