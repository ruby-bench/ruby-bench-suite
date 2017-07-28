require 'bundler/setup'
require 'pg'
require 'byebug'
require 'time'

require_relative 'support/benchmark_pg'

db_setup script: "bm_discourse_setup.rb"

conn = PG.connect(
  host: ENV.fetch("HOST", "localhost"),
  port: ENV.fetch("PORT", "5432"),
  dbname: ENV.fetch("DB_NAME", "rubybench"),
  user: ENV.fetch("DB_USER", "postgres"),
  password: ENV.fetch("DB_PASSWORD", "postgres")
)

def username(topic, users)
  users.select{ |user| user['id'] == topic[9] }.first['username']
end

user = conn.exec("SELECT * FROM users ORDER BY users.id LIMIT 1").first
Benchmark.pg("pg/discourse", time: 5) do
  str = ""

  topics = conn.exec(
    "
      SELECT
        topics.id,
        topics.created_at,
        topics.updated_at,
        topics.title,
        topics.bumped_at,
        topics.archetype,
        topics.deleted_at,
        topics.pinned_globally,
        topics.pinned_at,
        topics.user_id,
        topics.category_id,
        categories.id,
        categories.created_at,
        categories.updated_at,
        categories.topic_id
      FROM topics
      LEFT OUTER JOIN categories ON categories.id = topics.category_id
      LEFT OUTER JOIN topic_users AS tu ON (topics.id = tu.topic_id AND tu.user_id = #{user['id']})
      WHERE (
        (topics.archetype <> 'private_message')
        AND (COALESCE(categories.topic_id, 0) <> topics.id)
        AND (topics.deleted_at IS NULL)
        AND (
          NOT EXISTS (
            SELECT 1 FROM category_users cu
              WHERE cu.user_id = #{user['id']}
              AND cu.category_id = topics.category_id
              AND cu.notification_level = 0
              AND cu.category_id <> -1
              AND (tu.notification_level IS NULL OR tu.notification_level < 2)
          )
        )
        AND (
          pinned_globally
          AND pinned_at IS NOT NULL
          AND (topics.pinned_at > tu.cleared_pinned_at OR tu.cleared_pinned_at IS NULL)
        )
      )
      ORDER BY topics.bumped_at
      DESC
      LIMIT 30
    "
  )

  # Preload users
  user_ids = topics.map { |row| row['user_id'] }
  users = conn.exec("SELECT users.* FROM users WHERE users.id IN (#{user_ids.join(',')})")

  topics.each_row do |topic|
    str << "id: #{topic[0]} title: #{topic[3]} created_at: #{Time.parse(topic[1]).iso8601} user: #{username(topic, users)}\n"
  end
end
