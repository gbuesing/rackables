require 'test/unit'
require 'rackables'

class TestPublicExceptionPage < Test::Unit::TestCase

  def test_returns_downstream_app_response_when_no_exception_raised
    app = Proc.new { [200, {'Content-Type' => 'text/html'}, ['Downstream app']]}
    middleware = Rackables::PublicExceptionPage.new(app)
    status, headers, body = middleware.call({})
    assert_equal 200, status
    assert_equal ['Downstream app'], body
  end

  def test_returns_500_with_default_exception_page_when_exception_raised_by_downstream_app
    app = Proc.new { raise }
    middleware = Rackables::PublicExceptionPage.new(app)
    status, headers, body = middleware.call({})
    assert_equal 500, status
    assert_match /We\'re sorry, but something went wrong/, body[0]
  end

  def test_returns_500_with_custom_exception_page_when_file_path_specified
    app = Proc.new { raise }
    middleware = Rackables::PublicExceptionPage.new(app, 'test/fixtures/custom_500.html')
    status, headers, body = middleware.call({})
    assert_equal 500, status
    assert_match /Custom 500 page/, body[0]
  end

end