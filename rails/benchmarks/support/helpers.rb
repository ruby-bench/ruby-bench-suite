def db_adapter
  ENV['DATABASE_URL'].split(":")[0]
end

def db_setup(script:)
  `cd ../support/setup && DATABASE_URL=#{ENV.fetch("DATABASE_URL")} ruby #{script}`
end
