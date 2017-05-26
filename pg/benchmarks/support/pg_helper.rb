module PG
  class Helper
    def self.connect
      new
    end

    def initialize
      @connection = PG.connect(host: ENV.fetch("HOST", "localhost"),
                               port: ENV.fetch("PORT", "5432"),
                               dbname: ENV.fetch("DB_NAME", "rubybench"),
                               user: ENV.fetch("DB_USER", "postgres"),
                               password: ENV.fetch("DB_PASSWORD", "postgres"))
    end

    def drop_and_create_table_users
      @connection.exec("DROP TABLE IF EXISTS users;")
      @connection.exec("CREATE TABLE users ( name varchar(255), email varchar(255), admin boolean );")
    end

    def insert_user(name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', email: 'foobar@email.com')
      @connection.exec("INSERT INTO users VALUES ('#{name}', '#{email}', false);")
    end

    def insert_admin(name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', email: 'foobar@email.com')
      @connection.exec("INSERT INTO users VALUES ('#{name}', '#{email}', true);")
    end

    def all_users
      @connection.exec("SELECT * FROM users")
    end

    def all_admins
      @connection.exec("SELECT * FROM users WHERE admin IS TRUE")
    end
  end
end
