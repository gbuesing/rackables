require 'rack/utils'

module Rackables
  # Adds the specified charset to the Content-Type header, if one isn't
  # already there.
  #
  # Ideal for use with Sinatra, which by default doesn't set charset
  class DefaultCharset
    HAS_CHARSET = /;\s*charset\s*=\s*/i

    def initialize(app, value = 'utf-8')
      @app = app
      @value = value
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers = ::Rack::Utils::HeaderHash.new(headers)
      content_type = headers['Content-Type']
      if content_type && content_type !~ HAS_CHARSET
        headers['Content-Type'] = "#{content_type}; charset=#{@value}"
      end
      [status, headers, body]
    end
  end
end
