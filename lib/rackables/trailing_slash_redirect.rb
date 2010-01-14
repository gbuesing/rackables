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
      if env['PATH_INFO'] =~ HAS_TRAILING_SLASH
        location = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/#{$1}"
        location = "#{location}?#{env['QUERY_STRING']}" if env['QUERY_STRING'].to_s =~ /\S/
        [301, {"Location" => location}, []]
      else
        @app.call(env)
      end
    end

  end
end
