require 'test/unit'
require 'rackables'

class TestBranch < Test::Unit::TestCase

  def test_calls_app_returned_from_block
    app = Proc.new { [200, {}, ["Downstream app"]] }
    blog = Proc.new { [200, {}, ["Blog"]] }
    middleware = Rackables::Branch.new(app) do |env|
      blog if env['PATH_INFO'] =~ /^\/blog/
    end
    status, headers, body = middleware.call('PATH_INFO' => '/blog')
    assert_equal 'Blog', body[0]
  end

  def test_calls_app_passed_in_to_initialize_when_block_returns_false
    app = Proc.new { [200, {}, ["Downstream app"]] }
    blog = Proc.new { [200, {}, ["Blog"]] }
    middleware = Rackables::Branch.new(app) do |env|
      blog if env['PATH_INFO'] =~ /^\/blog/
    end
    status, headers, body = middleware.call('PATH_INFO' => '/foo')
    assert_equal 'Downstream app', body[0]
  end
  
  def test_calls_downstream_app_when_app_returned_from_block_returns_x_cascade_header
    app = Proc.new { [200, {}, ["Downstream app"]] }
    blog = Proc.new { [404, {'X-Cascade' => 'pass'}, []] }
    middleware = Rackables::Branch.new(app) do |env|
      blog if env['PATH_INFO'] =~ /^\/blog/
    end
    status, headers, body = middleware.call('PATH_INFO' => '/blog')
    assert_equal 'Downstream app', body[0]
  end

end