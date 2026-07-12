class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :user

  validates :user, :course, presence: true

  validates_uniqueness_of :course_id, scope: :user_id

  validate :cant_subscribe_to_own_course

  def to_s
    user.to_s + " --> " + course.to_s
  end


  scope :pending_review, -> { where(rating: nil, review: nil) }

  protected
  def cant_subscribe_to_own_course
    if self.new_record? &&  self.user.present? &&  self.user_id == self.course.user_id
      errors.add :base, "You can't subscribe to your own course"
    end
  end
end
