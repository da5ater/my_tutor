require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @course = courses(:one)
    @lesson = lessons(:one)
  end

  test "should get index" do
    get course_lessons_url(@course)
    assert_response :success
  end

  test "should get new" do
    get new_course_lesson_url(@course)
    assert_response :success
  end

  test "should create lesson" do
    assert_difference("Lesson.count") do
      post course_lessons_url(@course), params: { lesson: { content: "This is some valid lesson content that passes validation.", course_id: @course.id, title: "New Lesson Title" } }
    end

    assert_redirected_to course_lesson_url(@course, Lesson.last)
  end

  test "should show lesson" do
    second_lesson = lessons(:two)
    second_lesson.update_column(:course_id, @course.id)

    get course_lesson_url(@course, @lesson)

    assert_response :success
    assert_select "[data-lesson-curriculum]"
    assert_select "[data-curriculum-lesson]", count: 2
    assert_select "[data-curriculum-lesson='#{@lesson.id}'][aria-current='page']", count: 1
  end

  test "show cannot load a lesson through another course" do
    @user.add_role(:admin)

    get course_lesson_url(@course, lessons(:two))

    assert_response :not_found
  end

  test "should get edit" do
    get edit_course_lesson_url(@course, @lesson)
    assert_response :success
  end

  test "should update lesson" do
    patch course_lesson_url(@course, @lesson), params: { lesson: { content: "Updated lesson content that passes validation.", course_id: @course.id, title: "Updated Lesson Title" } }
    @lesson.reload
    assert_redirected_to course_lesson_url(@course, @lesson)
  end

  test "should destroy lesson" do
    assert_difference("Lesson.count", -1) do
      delete course_lesson_url(@course, @lesson)
    end

    assert_redirected_to course_path(@course)
  end

  test "show records an authorized lesson view once" do
  assert_difference("UserLesson.count", 1) do
    get course_lesson_url(@course, @lesson)
  end

  assert_response :success

  assert_no_difference("UserLesson.count") do
    get course_lesson_url(@course, @lesson)
  end
end
end
