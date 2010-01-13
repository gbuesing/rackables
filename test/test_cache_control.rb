require 'test/unit'
require 'rackables'

class TestCacheControl < Test::Unit::TestCase

  def test_sets_cache_control
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    assert_equal 'public, max-age=5', headers['Cache-Control']
  end

  def test_sets_cache_control_with_value_specified_as_proc
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :max_age => Proc.new {5})
    status, headers, body = middleware.call({})
    assert_equal 'public, max-age=5', headers['Cache-Control']
  end

  def test_respects_existing_cache_control_value
    app = Proc.new { [200, {'Cache-Control' => 'private'}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    assert_equal 'private', headers['Cache-Control']
  end

end