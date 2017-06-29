require 'bundler/setup'
require 'active_record'
require_relative 'support/benchmark_rails'

ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :topics, force: true do |t|
    t.timestamps null: false
    t.string "title"
    t.datetime "bumped_at"
    t.string "archetype"
    t.datetime "deleted_at"
    t.boolean "pinned_globally"
    t.datetime "pinned_at"
    t.integer "user_id", null: false
    t.integer "category_id"
  end

  create_table :topic_users, force: true do |t|
    t.timestamps null: false
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.integer "notification_level"
    t.datetime "cleared_pinned_at"
  end

  create_table :categories, force: true do |t|
    t.timestamps null: false
    t.integer "topic_id"
  end

  create_table :category_users, force: true do |t|
    t.timestamps null: false
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.integer "notification_level"
  end

  create_table :users, force: true do |t|
    t.timestamps null: false
    t.string "username"
  end
end

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

# Helpers

def archetype(i)
  if i % 4 == 0
    "not_private_message"
  else
    "private_message"
  end
end

def bumped_at(i, user_id)
  Time.at(50000 + i + user_id)
end

def deleted_at(i, user_id)
  if i % 3 == 0
    Time.at(100000 + i + user_id)
  end
end

def pinned_globally(i)
  i % 2 == 0
end

def pinned_at(i, user_id)
  if i % 2 == 0
    Time.at(1000 + i + user_id)
  end
end

def notification_level(i)
  i % 2 == 0 ? 1 : 0
end

def cleared_pinned_at(topic)
  if topic.pinned_at
    topic.pinned_at + 5
  end
end

# Stage DB

10.times do |i|
  User.create(username: "user#{i}")
end

User.all.each do |user|
  500.times do |i|
    user.topics.create(
      title: "#{user.username} topic #{i}",
      pinned_globally: pinned_globally(i),
      bumped_at: bumped_at(i, user.id),
      archetype: archetype(i),
      deleted_at: deleted_at(i, user.id),
      pinned_at: pinned_at(i, user.id)
    )
  end
end

200.times do |i|
  Category.create(topic: Topic.limit(1).offset(i).first)
end

Topic.last(100).each_with_index do |topic, i|
  topic.category = Category.offset(i).limit(1).first
end

User.all.each do |user|
  Topic.where.not(user: user).each_with_index do |topic, i|
    TopicUser.create(user: user, topic: topic, cleared_pinned_at: cleared_pinned_at(topic), notification_level: notification_level(i))
  end
end

user = User.create(username: "bmarkons")

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
      str << "id: #{topic.id} title: #{topic.title} created_at: #{topic.created_at} user: #{topic.user.username}\n"
    end
end
