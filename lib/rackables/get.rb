module Rackables
  # Simplest example:
  #
  #   use Rackables::Get, '/ping_monitor' do
  #     'pong'
  #   end
  #
  # Rack::Response object is yielded as second argument to block:
  #
  #   use Rackables::Get, '/json' do |env, response|
  #     response['Content-Type'] = 'application/json'
  #     %({"foo": "bar"})
  #   end
  #
  # Example with regular expression -- match data object is yielded as third argument to block
  #
  #   use Rackables::Get, %r{^/(john|paul|george|ringo)} do |env, response, match|
  #     "Hello, #{match[1]}"
  #   end
  #
  # A false/nil return from block will not return a response; control will continue down the
  # Rack stack:
  #
  #   use Rackables::Get, '/api_key' do |env, response|
  #     '12345' if env['myapp.user'].authorized?
  #   end
  class Get
    def initialize(app, path, &block)
      @app = app
      @path = path
      @block = block
    end

    def call(env)
      path, method = env['PATH_INFO'].to_s, env['REQUEST_METHOD']
      if method == 'GET' && ((@path.is_a?(Regexp) && match = @path.match(path)) || @path == path)
        response = ::Rack::Response.new
        response.body = @block.call(env, response, match)
        response.body ? response.finish : @app.call(env)
      else
        @app.call(env)
      end
    end
  end
end