require "test_helper"

class LessonTest < ActiveSupport::TestCase
  test "destroying a lesson destroys its viewing records" do
    lesson = lessons(:one)
    users(:one).view_lesson(lesson)

    assert_difference("UserLesson.count", -1) do
      lesson.destroy!
    end
  end
end
