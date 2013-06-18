require 'rack/utils'

module Rackables
  # Allows you to tap into the response headers. Yields a Rack::Utils::HeaderHash
  # of current response headers to the block. Example:
  #
  #   use Rackables::ResponseHeaders do |headers|
  #     headers['X-Foo'] = 'bar'
  #     headers.delete('X-Baz')
  #   end
  #
  class ResponseHeaders
    def initialize(app, &block)
      @app = app
      @block = block
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers = ::Rack::Utils::HeaderHash.new(headers)
      @block.call(headers)
      [status, headers, body]
    end
  end
end