require 'rack'

module Rackables
  # Simplest example:
  #
  #   use Rackables::SimpleEndpoint, '/ping_monitor' do
  #     'pong'
  #   end
  #
  # HTTP verb requirements can optionally be specified:
  #
  #   use Rackables::SimpleEndpoint, '/ping_monitor' => :get do
  #     'only GET requests will match'
  #   end
  #
  #   use Rackables::SimpleEndpoint, '/ping_monitor' => [:get, :post] do
  #     'only GET and POST requests will match'
  #   end
  #
  # Rack::Request Rack::Response objects are yielded to block:
  #
  #   use Rackables::SimpleEndpoint, '/json' do |request, response|
  #     response['Content-Type'] = 'application/json'
  #     %({"foo": "#{request[:foo]}"})
  #   end
  #
  # Example with regular expression -- match data object is yielded as third argument to block
  #
  #   use Rackables::SimpleEndpoint, %r{^/(john|paul|george|ringo)} do |request, response, match|
  #     "Hello, #{match[1]}"
  #   end
  #
  # A :pass symbol returned from block will not return a response; control will continue down the
  # Rack stack:
  #
  #   use Rackables::SimpleEndpoint, '/api_key' do |request, response|
  #     request.env['myapp.user'].authorized? ? '12345' : :pass
  #   end
  #
  #   # Unauthorized access to /api_key will receive a 404
  #   run NotFoundApp
  class SimpleEndpoint
    def initialize(app, arg, &block)
      @app    = app
      @path   = extract_path(arg)
      @verbs  = extract_verbs(arg)
      @block  = block
    end

    def call(env)
      match = match_path(env['PATH_INFO'])
      if match && valid_method?(env['REQUEST_METHOD'])
        request, response = ::Rack::Request.new(env), ::Rack::Response.new
        response.body = @block.call(request, response, (match unless match == true))
        response.body == :pass ? @app.call(env) : response.finish
      else
        @app.call(env)
      end
    end

    private
      def extract_path(arg)
        arg.is_a?(Hash) ? arg.keys.first : arg
      end

      def extract_verbs(arg)
        arg.is_a?(Hash) ? [arg.values.first].flatten.map {|verb| verb.to_s.upcase} : []
      end

      def match_path(path)
        @path.is_a?(Regexp) ? @path.match(path.to_s) : @path == path.to_s
      end

      def valid_method?(method)
        @verbs.empty? || @verbs.include?(method)
      end
  end
end