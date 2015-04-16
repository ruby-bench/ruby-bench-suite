require 'shellwords'
require 'uri'
require 'uri/http'
require 'digest/sha1'
require 'openssl'
require 'ostruct'
require 'fileutils'

module Cache
  class S3
    class AWS4Signature
      def initialize(key_pair, verb, location, expires, timestamp=Time.now)
        @key_pair = key_pair
        @verb = verb
        @location = location
        @expires = expires
        @timestamp = timestamp
      end

      def to_uri
        signature = OpenSSL::HMAC.hexdigest("sha256", signing_key, string_to_sign)
        query = "#{query_string}&X-Amz-Signature=#{signature}"

        URI::HTTP.build(
          scheme: @location.scheme,
          host: @location.hostname,
          path: @location.path,
          query: query,
        )
      end

      private

      def date
        @timestamp.utc.strftime('%Y%m%d')
      end

      def timestamp
        @timestamp.utc.strftime('%Y%m%dT%H%M%SZ')
      end

      def query_string
        canonical_query_params.map { |key, value|
          "#{URI.encode(key.to_s, /[^~a-zA-Z0-9_.-]/)}=#{URI.encode(value.to_s, /[^~a-zA-Z0-9_.-]/)}"
        }.join('&')
      end

      def request_sha
        OpenSSL::Digest::SHA256.hexdigest(
          [
            @verb,
            @location.path,
            query_string,
            "host:#{@location.hostname}\n",
            'host',
            'UNSIGNED-PAYLOAD'
          ].join("\n")
        )
      end

      def canonical_query_params
        @canonical_query_params ||= {
          'X-Amz-Algorithm' => 'AWS4-HMAC-SHA256',
          'X-Amz-Credential' => "#{@key_pair.id}/#{date}/#{@location.region}/s3/aws4_request",
          'X-Amz-Date' => timestamp,
          'X-Amz-Expires' => @expires,
          'X-Amz-SignedHeaders' => 'host',
        }
      end

      def string_to_sign
        [
          'AWS4-HMAC-SHA256',
          timestamp,
          "#{date}/#{@location.region}/s3/aws4_request",
          request_sha
        ].join("\n")
      end

      def signing_key
        @signing_key ||= recursive_hmac(
          "AWS4#{@key_pair.secret}",
          date,
          @location.region,
          's3',
          'aws4_request',
        )
      end

      def recursive_hmac(*args)
        args.inject { |key, data| OpenSSL::HMAC.digest('sha256', key, data) }
      end
    end

    MSGS = {
      config_missing: 'Worker S3 config missing: %s'
    }

    VALIDATE = {
      bucket:            'bucket name',
      access_key_id:     'access key id',
      secret_access_key: 'secret access key'
    }

    KeyPair = Struct.new(:id, :secret)

    Location = Struct.new(:scheme, :region, :bucket, :path) do
      def hostname
        "#{bucket}.#{region == 'us-east-1' ? 's3' : "s3-#{region}"}.amazonaws.com"
      end
    end

    # TODO: Switch to different branch from master?
    CASHER_URL = 'https://raw.githubusercontent.com/travis-ci/casher/%s/bin/casher'
    # USE_RUBY   = '1.9.3'
    CASHER_DIR = "#{ENV['HOME']}/.casher"
    BIN_PATH   = "#{CASHER_DIR}/bin/casher"

    attr_reader :data, :msgs

    def initialize(data)
      @data = data
      @msgs = []
    end

    def valid?
      validate
      msgs.empty?
    end

    def setup
      install
      fetch
      directories.each { |dir| add(dir) }
    end

    def install
      ::FileUtils.mkdir_p("#{CASHER_DIR}/bin")
      `curl -s #{casher_url} -L -o #{BIN_PATH}`

      if File.exist?(BIN_PATH)
        `chmod +x #{BIN_PATH}`
      end
    end

    def add(path)
      run('add', path) if path
    end

    def fetch
      urls = [Shellwords.escape(fetch_url.to_s)]
      run('fetch', urls)
    end

    def push
      run('push', Shellwords.escape(push_url.to_s), assert: false)
    end

    def fetch_url
      url('GET', prefixed, expires: fetch_timeout)
    end

    def push_url
      url('PUT', prefixed, expires: push_timeout)
    end

    private

    def validate
      VALIDATE.each { |key, msg| msgs << msg unless s3_options[key] }
      raise MSGS[:config_missing] % msgs.join(', ') unless msgs.empty?
    end

    def run(command, args, options = {})
      if File.exist?(BIN_PATH)
        run_ruby("#{BIN_PATH} #{command} #{Array(args).join(' ')}")
      end
    end

    def run_ruby(command)
      `ruby #{command}`
    end

    def group
      data.group
    end

    def directories
      Array(data.cache[:directories])
    end

    def fetch_timeout
      options.fetch(:fetch_timeout)
    end

    def push_timeout
      options.fetch(:push_timeout)
    end

    def location(path)
      Location.new(
        s3_options.fetch(:scheme, 'https'),
        s3_options.fetch(:region, 'us-east-1'),
        s3_options.fetch(:bucket),
        path
      )
    end

    def prefixed
      args = [data.key]
      args.map! { |arg| arg.to_s.gsub(/[^\w\.\_\-]+/, '') }
      '/' << args.join('/') << '.tbz'
    end

    def url(verb, path, options = {})
      AWS4Signature.new(key_pair, verb, location(path), options[:expires], Time.now).to_uri.to_s.untaint
    end

    def key_pair
      KeyPair.new(s3_options[:access_key_id], s3_options[:secret_access_key])
    end

    def s3_options
      options[:s3] || {}
    end

    def options
      data.cache_options || {}
    end

    def casher_url
      CASHER_URL % casher_branch
    end

    def casher_branch
      'production'
    end
  end
end

data = OpenStruct.new
data.cache_options = {
  fetch_timeout: 10*60,
  push_timeout: 80*60,
  s3: {
    access_key_id: ENV['S3_ACCESS_KEY'],
    secret_access_key: ENV['S3_ACCESS_SECRET'],
    bucket: 'rubybench',
  }
}
data.key = "rails#{ENV['RAILS_VERSION']}"
data.cache = {
  directories: "/ruby-bench-suite/rails/vendor/bundle"
}

cache = Cache::S3.new(data)

if ARGV[0] == "fetch"
  cache.valid?
  cache.setup
else
  cache.push
end
