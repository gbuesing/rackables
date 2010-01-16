module Rackables
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
  #
  # If the app returned from the block responds with an X-Cascade: pass header,
  # control will be passed back to the main rack pipeline.
  #
  # In this contrived example, MyEndpointApp will always be called:
  #
  #   use Rackables::Branch do |env|
  #     Proc.new { [404, 'X-Cascade' => 'pass', []] }
  #   end
  #
  #   run MyEndpointApp
  class Branch
    def initialize(app, &block)
      @app = app
      @block = block
    end

    def call(env)
      if branch_app = @block.call(env)
        response = branch_app.call(env)
        cascade = response[1]['X-Cascade']
        cascade == 'pass' ? @app.call(env) : response
      else
        @app.call(env)
      end
    end
  end
end