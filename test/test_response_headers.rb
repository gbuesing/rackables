require 'test/unit'
require 'rackables'

class TestResponseHeaders < Test::Unit::TestCase

  def test_yields_a_rack_utils_header_hash_of_downstream_response_headers
    orig_headers = {'X-Foo' => 'foo', 'X-Bar' => 'bar'}
    app = Proc.new {[200, orig_headers, []]}
    middleware = Rackables::ResponseHeaders.new(app) do |headers|
      assert_instance_of Rack::Utils::HeaderHash, headers
      assert_equal orig_headers, headers
    end
    middleware.call({})
  end

  def test_allows_adding_of_headers
    app = Proc.new {[200, {'X-Foo' => 'foo'}, []]}
    middleware = Rackables::ResponseHeaders.new(app) do |headers|
      headers['X-Bar'] = 'bar'
    end
    r = middleware.call({})
    assert_equal({'X-Foo' => 'foo', 'X-Bar' => 'bar'}, r[1])
  end

  def test_allows_deleting_of_headers
    app = Proc.new {[200, {'X-Foo' => 'foo', 'X-Bar' => 'bar'}, []]}
    middleware = Rackables::ResponseHeaders.new(app) do |headers|
      headers.delete('X-Bar')
    end
    r = middleware.call({})
    assert_equal({'X-Foo' => 'foo'}, r[1])
  end

end