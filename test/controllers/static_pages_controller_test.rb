require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get privacy_policy" do
    get privacy_policy_url
    assert_response :success
  end
end
