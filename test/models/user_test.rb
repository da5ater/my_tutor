require "test_helper"

class UserTest < ActiveSupport::TestCase
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
