module Rackables
  # Returns a user-friendly exception page
  # Should be included at the very top of the middleware pipeline so that unhandled exceptions from anywhere down the pipeline are rescued
  # In development, you'd want to use Rack::ShowExceptions instead of this (config.ru example):
  #
  #   if ENV['RACK_ENV'] == 'development'
  #     use Rack::ShowExceptions
  #   else
  #     use Rackables::PublicExceptionPage
  #   end
  #
  # The default HTML included here is a copy of the 500 page included with Rails
  # You can optionally specify your own file, ex:
  #
  #   use Rackables::PublicExceptionPage, "public/500.html"
  class PublicExceptionPage

    def initialize(app, file_path = nil)
      @app = app
      @file_path = file_path
    end

    def call(env)
      @app.call(env)
    rescue ::Exception
      [500, {'Content-Type' => 'text/html', 'Content-Length' => html.length.to_s}, [html]]
    end

    private

      def html
        @html ||= @file_path ? ::File.read(@file_path) : default_html
      end

      # Exception page from Rails (500.html)
      def default_html
        <<-EOV
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
               "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

        <head>
          <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
          <title>We're sorry, but something went wrong (500)</title>
        	<style type="text/css">
        		body { background-color: #fff; color: #666; text-align: center; font-family: arial, sans-serif; }
        		div.dialog {
        			width: 25em;
        			padding: 0 4em;
        			margin: 4em auto 0 auto;
        			border: 1px solid #ccc;
        			border-right-color: #999;
        			border-bottom-color: #999;
        		}
        		h1 { font-size: 100%; color: #f00; line-height: 1.5em; }
        	</style>
        </head>

        <body>
          <!-- This file lives in public/500.html -->
          <div class="dialog">
            <h1>We're sorry, but something went wrong.</h1>
            <p>We've been notified about this issue and we'll take a look at it shortly.</p>
          </div>
        </body>
        </html>
        EOV
      end

  end
end
