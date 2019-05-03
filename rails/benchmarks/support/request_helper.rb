module RequestHelper
  def self.perform(app, request)
    status, _, body = app.call(request)
    raise "Error: response status: #{status}" if status != 200
    body.close if body.respond_to?(:close)
  end
end
