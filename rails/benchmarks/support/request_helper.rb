module RequestHelper
  VALID_STATUS = [200, 302]

  def self.perform(app, request)
    status, _, body = app.call(request)
    raise "Error: response status: #{status}" unless VALID_STATUS.include?(status)
    body.close if body.respond_to?(:close)
  end
end
