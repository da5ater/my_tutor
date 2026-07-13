require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "progress is zero for a course without lessons" do
    course = courses(:one)
    course.lessons.destroy_all

    assert_equal 0.0, course.progress_for(users(:one))
  end

  test "progress is the percentage of this course lessons viewed by the user" do
    course = courses(:one)
    user = users(:one)
    second_lesson = lessons(:two)
    second_lesson.update_column(:course_id, course.id)
    user.user_lessons.delete_all

    user.view_lesson(lessons(:one))

    assert_in_delta 50.0, course.progress_for(user)
  end

  test "progress ignores lessons viewed in another course" do
    course = courses(:one)
    user = users(:one)
    user.user_lessons.delete_all

    user.view_lesson(lessons(:two))

    assert_equal 0.0, course.progress_for(user)
  end

  test "progress is zero without a user" do
    assert_equal 0.0, courses(:one).progress_for(nil)
  end

  test "a course with enrollments cannot be destroyed" do
    course = courses(:one)

    assert_no_difference("Course.count") do
      assert_not course.destroy
    end

    assert course.errors[:base].any?
  end
end
