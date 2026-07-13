require "test_helper"

class CoursePublicationTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @owner.add_role(:teacher)
    @course = courses(:one)
    @other_course = courses(:two)
  end

  test "public catalog and homepage expose only published and approved courses" do
    @course.update_columns(published: true, approved: true)
    @other_course.update_columns(published: true, approved: false)

    get courses_url
    assert_response :success
    assert_select "##{dom_id(@course)}"
    assert_select "##{dom_id(@other_course)}", count: 0

    get root_url
    assert_response :success
    assert_select "##{dom_id(@course)}"
    assert_select "##{dom_id(@other_course)}", count: 0
  end

  test "creator can still see a draft in created courses" do
    @course.update_columns(published: false, approved: false)
    sign_in @owner

    get created_courses_url

    assert_response :success
    assert_select "##{dom_id(@course)}"
    assert_select "[data-course-publication-status='#{@course.id}']", text: /Draft/
  end

  test "administrator cannot edit another creator's course content" do
    admin = users(:two)
    admin.add_role(:admin)
    sign_in admin

    get edit_course_url(@course)

    assert_redirected_to root_url
  end

  test "an existing buyer can still open an unpublished course" do
    @course.update_columns(published: false, approved: true)
    buyer = users(:two)
    Enrollment.find_or_create_by!(user: buyer, course: @course) { |enrollment| enrollment.price = @course.price }
    sign_in buyer

    get course_url(@course)

    assert_response :success
  end

  test "anonymous visitor cannot open a draft directly" do
    @course.update_columns(published: false, approved: false)

    get course_url(@course)

    assert_redirected_to root_url
  end

  test "unavailable course cannot accept a new enrollment" do
    @course.update_columns(published: true, approved: false)
    sign_in users(:two)

    get new_course_enrollment_url(@course)

    assert_redirected_to root_url
  end

  test "admin can approve and withdraw approval" do
    admin = users(:two)
    admin.add_role(:admin)
    sign_in admin
    @course.update!(
      description: "A complete course description that is safely longer than fifty characters for approval testing.",
      published: true,
      approved: false
    )

    patch "/courses/#{@course.to_param}/approve"
    assert_redirected_to course_url(@course)
    assert @course.reload.approved?

    patch "/courses/#{@course.to_param}/unapprove"
    assert_redirected_to course_url(@course)
    assert_not @course.reload.approved?
  end

  test "teacher cannot approve a course" do
    sign_in @owner
    @course.update_columns(published: true, approved: false)

    patch "/courses/#{@course.to_param}/approve"

    assert_redirected_to root_url
    assert_not @course.reload.approved?
  end

  test "admin moderation queue contains only unapproved courses" do
    admin = users(:one)
    admin.add_role(:admin)
    sign_in admin
    @course.update_column(:approved, false)
    @other_course.update_column(:approved, true)

    get "/courses/unapproved"

    assert_response :success
    assert_select "##{dom_id(@course)}"
    assert_select "##{dom_id(@other_course)}", count: 0
    assert_select "a[href='/courses/unapproved']", text: /Course approvals/
  end
end
