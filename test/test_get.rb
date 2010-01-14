require 'test/unit'
require 'rackables'
require 'rubygems'
require 'rack'

class TestGet < Test::Unit::TestCase

  def setup
    @app = Proc.new { [200, {}, ["Downstream app"]] }
  end

  def test_calls_downstream_app_when_no_match
    middleware = Rackables::Get.new(@app, '/foo') { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/bar', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'Downstream app', body[0]
  end

  def test_calls_downstream_app_when_path_matches_but_request_method_is_not_get
    middleware = Rackables::Get.new(@app, '/foo') { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'POST')
    assert_equal 200, status
    assert_equal 'Downstream app', body[0]
  end

  def test_calls_downstream_app_when_path_matches_but_block_returns_nil
    middleware = Rackables::Get.new(@app, '/foo') {  }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'Downstream app', body[0]
  end

  def test_get_returns_response_when_string_path_arg_matches_path_info
    middleware = Rackables::Get.new(@app, '/foo') { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', body.body
  end

  def test_get_returns_response_when_string_path_arg_matches_regex
    middleware = Rackables::Get.new(@app, /foo/) { 'bar' }
    status, headers, body = middleware.call('PATH_INFO' => '/bar/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', body.body
  end

  def test_block_yields_env
    env = {'PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET'}
    middleware = Rackables::Get.new(@app, '/foo') do |e, resp|
      assert_equal env, e
    end
    status, headers, body = middleware.call(env)
  end

  def test_block_yields_response_obj
    env = {'PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET'}
    middleware = Rackables::Get.new(@app, '/foo') do |e, resp|
      assert_instance_of ::Rack::Response, resp
    end
    status, headers, body = middleware.call(env)
  end

  def test_block_yields_match_data
    env = {'PATH_INFO' => '/foobar', 'REQUEST_METHOD' => 'GET'}
    middleware = Rackables::Get.new(@app, /foo(.+)/) do |e, resp, match|
      assert_instance_of MatchData, match
      assert_equal 'bar', match[1]
    end
    status, headers, body = middleware.call(env)
  end

  def test_response_honors_headers_set_in_block
    middleware = Rackables::Get.new(@app, '/foo') {|e, r| r['X-Foo'] = 'bar'; 'baz' }
    status, headers, body = middleware.call('PATH_INFO' => '/foo', 'REQUEST_METHOD' => 'GET')
    assert_equal 200, status
    assert_equal 'bar', headers['X-Foo']
    assert_equal 'baz', body.body
  end

end