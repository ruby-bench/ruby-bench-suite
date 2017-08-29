STRING_COLUMNS_COUNT = 25

def db_adapter
  ENV['DATABASE_URL'].split(":")[0]
end

def db_setup(script:)
  Dir.chdir("../../support/setup") do
    `DATABASE_URL=#{ENV.fetch("DATABASE_URL")} BUNDLE_GEMFILE=Gemfile ruby #{script}`
  end
end
