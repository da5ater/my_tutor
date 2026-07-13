require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end


  test "admin can view analytics" do
    admin = users(:one)
    admin.add_role(:admin)
    sign_in admin

    get "/analytics"

    assert_response :success
    assert_select "[data-analytics-dashboard]"
    assert_select "[data-chart]", count: 5
    assert_select "a[href='/analytics']", text: /Analytics/
    assert_includes response.body, "/charts/users_per_day"
    assert_includes response.body, "/charts/enrollments_per_day"
    assert_includes response.body, "/charts/course_popularity"
    assert_includes response.body, "/charts/moneymakers"
    assert_includes response.body, "/charts/lesson_impressions"
    assert_includes response.body, '"chartkick": "/assets/chartkick-'
    assert_includes response.body, '"Chart.bundle": "/assets/Chart.bundle-'
  end


  test "admin can fetch lazy analytics series" do
    admin = users(:one)
    admin.add_role(:admin)
    sign_in admin

    get "/charts/users_per_day"
    assert_response :success
    assert_equal "application/json", response.media_type

    get "/charts/enrollments_per_day"
    assert_response :success

    get "/charts/course_popularity"
    assert_response :success

    get "/charts/moneymakers"
    assert_response :success
    assert_equal "application/json", response.media_type

    get "/charts/lesson_impressions"
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "non-admin cannot fetch analytics series directly" do
    sign_in users(:two)

    get "/charts/users_per_day"

    assert_redirected_to root_url
  end

  test "non-admin cannot view analytics" do
    sign_in users(:two)

    get "/analytics"

    assert_redirected_to root_url
  end

  test "non-admin cannot view activity" do
    sign_in users(:two)

    get activity_url

    assert_redirected_to root_url
  end
end
