require "test_helper"

class UserLessonTest < ActiveSupport::TestCase
  test "user and lesson pair is unique" do
    user = users(:one)
    lesson = lessons(:one)

    UserLesson.create(user: user, lesson: lesson)
    duplicate = UserLesson.new(user: user, lesson: lesson)
    assert_not duplicate.valid?
  end
end
