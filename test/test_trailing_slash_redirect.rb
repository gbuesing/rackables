require 'test/unit'
require 'rackables'

class TestTrailingSlashRedirect < Test::Unit::TestCase

  def test_passes_to_downstream_app_when_no_trailing_slash_on_path_info
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, ['Downstream app']]}
    middleware = Rackables::TrailingSlashRedirect.new(app)
    status, headers, body = middleware.call({'PATH_INFO' => '/foo'})
    assert_equal 200, status
    assert_equal ['Downstream app'], body
    assert_nil headers['Location']
  end

  def test_returns_301_when_trailing_slash_on_path_info
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, ['Downstream app']]}
    middleware = Rackables::TrailingSlashRedirect.new(app)
    status, headers, body = middleware.call({'rack.url_scheme' => 'http', 'HTTP_HOST' => 'bar.com', 'PATH_INFO' => '/foo/'})
    assert_equal 301, status
    assert_equal 'http://bar.com/foo', headers['Location']
  end

  def test_301_respects_query_string
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, ['Downstream app']]}
    middleware = Rackables::TrailingSlashRedirect.new(app)
    status, headers, body = middleware.call({'rack.url_scheme' => 'http', 'HTTP_HOST' => 'bar.com', 'PATH_INFO' => '/foo/', 'QUERY_STRING' => 'baz=hi'})
    assert_equal 301, status
    assert_equal 'http://bar.com/foo?baz=hi', headers['Location']
  end

  def test_301_respects_https
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, ['Downstream app']]}
    middleware = Rackables::TrailingSlashRedirect.new(app)
    status, headers, body = middleware.call({'rack.url_scheme' => 'https', 'HTTP_HOST' => 'bar.com', 'PATH_INFO' => '/foo/', 'QUERY_STRING' => 'baz=hi'})
    assert_equal 301, status
    assert_equal 'https://bar.com/foo?baz=hi', headers['Location']
  end

end