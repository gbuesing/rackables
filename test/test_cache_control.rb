require 'test/unit'
require 'rackables'

class TestCacheControl < Test::Unit::TestCase

  def test_sets_cache_control_with_value_set_as_integer
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    assert_equal 'public, max-age=5', headers['Cache-Control']
  end
  
  def test_sets_cache_control_with_value_set_as_string
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :community => "UCI")
    status, headers, body = middleware.call({})
    assert_equal %(public, community="UCI"), headers['Cache-Control']
  end

  def test_sets_cache_control_with_value_specified_as_proc_which_is_called_at_runtime
    app = Proc.new { [200, {}, []]}
    value = 7 #compile-time value
    middleware = Rackables::CacheControl.new(app, :public, :max_age => Proc.new {value})
    value = 5 #runtime value
    status, headers, body = middleware.call({})
    assert_equal 'public, max-age=5', headers['Cache-Control']
  end
  
  def test_sets_cache_control_with_multiple_values
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :private, :no_cache, :must_revalidate)
    status, headers, body = middleware.call({})
    assert_equal %(private, no-cache, must-revalidate), headers['Cache-Control']
  end
  
  def test_sets_true_value
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :private, :must_revalidate => true)
    status, headers, body = middleware.call({})
    assert_equal 'private, must-revalidate', headers['Cache-Control']
  end
  
  def test_does_not_set_false_value
    app = Proc.new { [200, {}, []]}
    middleware = Rackables::CacheControl.new(app, :private, :must_revalidate => false)
    status, headers, body = middleware.call({})
    assert_equal 'private', headers['Cache-Control']
  end

  def test_respects_existing_cache_control_header
    app = Proc.new { [200, {'Cache-Control' => 'private'}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    assert_equal 'private', headers['Cache-Control']
  end

  def test_respects_existing_cache_control_header_case_insensitive
    app = Proc.new { [200, {'Cache-control' => 'private'}, []]}
    middleware = Rackables::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    assert_equal 'private', headers['Cache-Control']
  end

end