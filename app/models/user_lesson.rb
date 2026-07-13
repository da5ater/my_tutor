class UserLesson < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lesson

  validates :user_id, uniqueness: { scope: :lesson_id }
end
