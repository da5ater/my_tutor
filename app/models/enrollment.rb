class Enrollment < ApplicationRecord
  belongs_to :course, counter_cache: true
  belongs_to :user, counter_cache: true

  validates :user, :course, presence: true

  validates :rating, presence: true, if: :review?

  validates_uniqueness_of :course_id, scope: :user_id

  validate :cant_subscribe_to_own_course

  extend FriendlyId
  friendly_id :to_s, use: :slugged

  after_save :update_course_rating
  after_destroy :update_course_rating


  scope :pending_review, -> { where(rating: nil, review: nil) }
  scope :reviewed, -> { where.not(review: [ nil, "" ]) }
  scope :latest_good_reviews, -> { order(rating: :desc, created_at: :desc).limit(3) }

  def to_s
    user.to_s + " --> " + course.to_s
  end


    def rating?
      rating.present?
    end

    def review?
      review.present?
    end

    def update_course_rating
      course.update_rating if course.present?
    end



  def self.ransackable_attributes(auth_object = nil)
    [  "created_at", "id", "rating", "review", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "course", "user" ]
  end

  protected
  def cant_subscribe_to_own_course
    if new_record? && user.present? && course.present? && user_id == course.user_id
      errors.add :base, "You can't subscribe to your own course"
    end
  end
end
