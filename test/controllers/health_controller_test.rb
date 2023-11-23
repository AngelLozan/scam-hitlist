require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "should get readiness" do
    get health_readiness_url
    assert_response :success
  end

  test "should get liveness" do
    get health_liveness_url
    assert_response :success
  end
end
