# Rackables::Branch lets you conditionally re-route the Rack stack at runtime to
# an alternate endpoint.
#
# You initialize this middleware with a block, which should either 1. return a
# valid rack endpoint, when want to branch away from the current Rack pipeline,
# or 2. nil/false, when you want to continue on. The block is passed the current
# Rack env hash.
#
# config.ru usage example:
#
#   use Rackables::Branch do |env|
#     ApiApp if env["PATH_INFO"] =~ /\.xml$/
#   end
#
#   run MyEndpointApp
#
# A slightly more complex example with multiple endpoints:
#
#   use Rackables::Branch do |env|
#     if env['PATH_INFO'] =~ %r{^\/foo\/(bar|baz)(.*)$/}
#       env['PATH_INFO'] = $2
#       {'bar' => BarApp, 'baz' => BazApp}[$1]
#     end
#   end
#
#   run MyEndpointApp
module Rackables
  class Branch
    def initialize(app, &block)
      @app = app
      @block = block
    end

    def call(env)
      app = @block.call(env) || @app
      app.call(env)
    end
  end
end