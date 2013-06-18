module Rackables
  # Request paths with a trailing slash are 301 redirected to the version without, e.g.:
  #
  #   GET /foo/   # => 301 redirects to /foo
  class TrailingSlashRedirect
    HAS_TRAILING_SLASH = %r{^/(.*)/$}

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.path_info =~ HAS_TRAILING_SLASH
        req.path_info = "/#{$1}"
        [301, {"Location" => req.url}, []]
      else
        @app.call(env)
      end
    end

  end
end
