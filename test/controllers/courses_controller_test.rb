require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @course = courses(:one)
  end

  test "should get index" do
    get courses_url
    assert_response :success
  end

  test "should get new" do
    get new_course_url
    assert_response :success
  end

  test "should create course" do
    assert_difference("Course.count") do
      post courses_url, params: { course: { description: "This is a test course description for testing purposes. It is at least 50 characters long to meet the minimum length requirement.", title: "Test Course" } }
    end

    assert_redirected_to course_url(Course.last)
  end

  test "should show course" do
    get course_url(@course)
    assert_response :success
  end

  test "should get edit" do
    get edit_course_url(@course)
    assert_response :success
  end

  test "should update course" do
  patch course_url(@course), params: { course: { description: "This is an updated course description that is definitely longer than fifty characters to pass model validation.", title: "Updated Rails 8 Course" } }
  assert_redirected_to course_url(@course)
end

  test "should destroy course" do
    assert_difference("Course.count", -1) do
      delete course_url(@course)
    end

    assert_redirected_to courses_url
  end
end
