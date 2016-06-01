module RequestHelper
  def self.perform(app, request)
    _, _, body = app.call(request)
    body.close if body.respond_to?(:close)
  end
end
