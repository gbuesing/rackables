module Rackables
  class DefaultCharset
    HAS_CHARSET = /charset=/

    def initialize(app, value = 'utf-8')
      @app = app
      @value = value
    end

    def call(env)
      status, headers, body = @app.call(env)
      content_type = headers['Content-Type']
      if content_type && content_type !~ HAS_CHARSET
        headers['Content-Type'] = "#{content_type}; charset=#{@value}"
      end
      [status, headers, body]
    end
  end
end
