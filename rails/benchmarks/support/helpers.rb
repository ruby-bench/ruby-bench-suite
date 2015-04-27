def db_adapter
  ENV['DATABASE_URL'].split(":")[0]
end
