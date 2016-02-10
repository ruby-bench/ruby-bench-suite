require 'action_cable'
require 'rack/mock'
require 'faye/websocket'
require 'active_support/core_ext/hash/indifferent_access'
require 'pathname'
require 'puma'

module Rails
  def self.root
    Pathname.pwd
  end
end

::Object.const_set(:ApplicationCable, Module.new)

class ApplicationCable::Channel < ActionCable::Channel::Base
end

class ApplicationCable::Connection < ActionCable::Connection::Base
end

ActionCable.instance_variable_set(:@server, nil)
server = ActionCable.server
server.config = ActionCable::Server::Configuration.new
inner_logger = ActiveSupport::Logger.new(STDOUT)
server.config.logger = ActionCable::Connection::TaggedLoggerProxy.new(inner_logger, tags: [])

# and now the "real" setup for our test:
server.config.disable_request_forgery_protection = true

if Dir.pwd.include?('support')
  server.config.channel_load_paths = [File.expand_path(Dir.pwd, __dir__)]
else
  server.config.channel_load_paths = [File.expand_path('support', __dir__)]
end

def with_puma_server(rack_app = ActionCable.server, port, config)
  ActionCable.server.config.cable = config
  server = ::Puma::Server.new(rack_app, ::Puma::Events.strings)
  server.add_tcp_listener '127.0.0.1', port
  server.min_threads = 1
  server.max_threads = 4

  t = Thread.new { server.run.join }
  yield port

ensure
  server.stop(true)
  t.join
end

MSG = JSON.dump command: 'message', identifier: JSON.dump(channel: 'EchoChannel'), data: JSON.dump(action: 'ding', message: 'hello')
SUB = JSON.dump command: 'subscribe', identifier: JSON.dump(channel: 'EchoChannel')
