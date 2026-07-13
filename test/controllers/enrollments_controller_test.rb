require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @enrollment = enrollments(:one)
    @course = courses(:two)
  end

  test "should get index" do
    @user.add_role(:admin)
    get enrollments_url
    assert_response :success
    assert_select "[data-course-progress='#{@enrollment.course_id}'][data-progress-user='#{@enrollment.user_id}']"
    assert_select "[role='progressbar'][aria-valuenow='0']"
  end


  test "should get nested new" do
    get new_course_enrollment_url(@course)
    assert_response :success
  end


  test "should buy free course" do
    @course.update_column(:price, 0)

    assert_difference("Enrollment.count") do
      post course_enrollments_url(@course)
    end

    assert_redirected_to course_url(@course)
  end

  test "should show owned enrollment" do
    get enrollment_url(@enrollment)
    assert_response :success
  end

  test "should get edit" do
    get edit_enrollment_url(@enrollment)
    assert_response :success
  end

  test "should update enrollment" do
    patch enrollment_url(@enrollment), params: {
       enrollment: {  rating: 5, review: "Great Course" } }
    assert_redirected_to course_url(@enrollment.course)
    assert_equal 5, @enrollment.reload.rating
  end

  test "should destroy enrollment" do
    assert_difference("Enrollment.count", -1) do
      delete enrollment_url(@enrollment)
    end

    assert_redirected_to enrollments_url
  end
end
