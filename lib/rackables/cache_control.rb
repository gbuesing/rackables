module Rackables
  class CacheControl
    # Works well with Varnish
    # TODO: accomodate more options than just public, max-age=
    def initialize(app, value, opts)
      @app = app
      @value = value
      @opts = opts
    end

    def call(env)
      response = @app.call(env)
      headers = response[1]
      if headers['Cache-Control'].nil?
        max_age = @opts[:max_age]
        max_age = max_age.call if max_age.respond_to?(:call)
        headers['Cache-Control'] = "#{@value}, max-age=#{max_age}"
      end
      response
    end
  end
end
