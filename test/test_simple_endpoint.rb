require 'test/unit'
require 'rackables'

class TestSimpleEndpoint < Test::Unit::TestCase

  def setup
    @app = Proc.new { [200, {}, ["Downstream app"]] }
  end

  def test_calls_downstream_app_when_no_match
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo') { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/bar', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'Downstream app', body[0]
  end

  def test_calls_downstream_app_when_path_matches_but_request_method_does_not_match
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo' => :get) { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'POST')
    assert_equal 200, status
    assert_equal 'Downstream app', body[0]
  end

  def test_calls_downstream_app_when_path_matches_but_block_returns_pass_symbol
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo') { :pass }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'Downstream app', body[0]
  end

  def test_get_returns_response_when_string_path_arg_matches_path_info
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo') { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', body.body
  end

  def test_get_returns_response_when_string_path_arg_matches_path_info_with_single_method_requirement
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo' => :get) { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', body.body
  end

  def test_get_returns_response_when_string_path_arg_matches_path_info_with_multiple_method_requirements
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo' => [:get, :post]) { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'POST')
    assert_equal 200, status
    assert_equal 'bar', body.body
  end

  def test_get_returns_response_when_string_path_arg_matches_regex
    middleware = Rackables::SimpleEndpoint.new(@app, /foo/) { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/bar/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', body.body
  end

  def test_block_yields_request_obj
    env = {'PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET'}
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo') do |req, resp|
      assert_instance_of ::Rack::Request, req
    end
    status, headers, body = middleware.call(env)
  end

  def test_block_yields_response_obj
    env = {'PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET'}
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo') do |req, resp|
      assert_instance_of ::Rack::Response, resp
    end
    status, headers, body = middleware.call(env)
  end

  def test_block_yields_match_data
    env = {'PATH_INFO' => '/foobar', 'REQUEST_METHOD' => 'GET'}
    middleware = Rackables::SimpleEndpoint.new(@app, /foo(.+)/) do |req, resp, match|
      assert_instance_of MatchData, match
      assert_equal 'bar', match[1]
    end
    status, headers, body = middleware.call(env)
  end

  def test_response_honors_headers_set_in_block
    middleware = Rackables::SimpleEndpoint.new(@app, '/foo') {|e, r| r['X-Foo'] = 'bar'; 'baz' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', headers['X-Foo']
    assert_equal 'baz', body.body
  end

end