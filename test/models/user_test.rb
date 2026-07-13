require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "viewing a lesson counts every impression without duplicating the viewing record" do
    user = users(:one)
    lesson = lessons(:one)
    user.user_lessons.where(lesson: lesson).delete_all

    first_view = nil
    assert_difference("UserLesson.count", 1) do
      first_view = user.view_lesson(lesson)
    end
    assert_equal 1, first_view.impressions

    second_view = nil
    assert_no_difference("UserLesson.count") do
      second_view = user.view_lesson(lesson)
    end
    assert_equal 2, second_view.impressions
  end

  test "destroying a user anonymizes historical records instead of deleting them" do
    user = users(:one)
    course = courses(:one)
    enrollment = enrollments(:one)
    user_lesson = UserLesson.create!(user: user, lesson: lessons(:one))

    user.destroy!

    assert_nil course.reload.user_id
    assert_nil enrollment.reload.user_id
    assert_nil user_lesson.reload.user_id
  end

  test "an anonymized enrollment remains valid" do
    enrollment = enrollments(:one)
    enrollment.update_column(:user_id, nil)

    assert enrollment.valid?
  end
end
