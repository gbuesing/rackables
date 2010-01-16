require 'test/unit'
require 'rackables'

class TestDefaultCharset < Test::Unit::TestCase

  def test_adds_utf8_charset_by_default
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, []]}
    middleware = Rackables::DefaultCharset.new(app)
    status, headers, body = middleware.call({})
    assert_equal 'text/html; charset=utf-8', headers['Content-Type']
  end

  def test_adds_specified_charset
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, []]}
    middleware = Rackables::DefaultCharset.new(app, 'us-ascii')
    status, headers, body = middleware.call({})
    assert_equal 'text/html; charset=us-ascii', headers['Content-Type']
  end

  def test_does_not_overwrite_existing_charset_value
    app = Proc.new { [200, {'Content-Type' => 'text/html; charset=us-ascii'}, []]}
    middleware = Rackables::DefaultCharset.new(app, 'iso-8859-2')
    status, headers, body = middleware.call({})
    assert_equal 'text/html; charset=us-ascii', headers['Content-Type']
  end
  
  def test_does_not_overwrite_existing_charset_value_is_case_insensitive
    app = Proc.new { [200, {'Content-type' => 'text/html; charset=us-ascii'}, []]}
    middleware = Rackables::DefaultCharset.new(app, 'iso-8859-2')
    status, headers, body = middleware.call({})
    assert_equal 'text/html; charset=us-ascii', headers['Content-Type']
  end

end