class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable, :trackable, :confirmable


  has_many :courses, dependent: :nullify
  has_many :enrollments, dependent: :nullify
  has_many :user_lessons, dependent: :nullify
  has_many :viewed_lessons, through: :user_lessons, source: :lesson

  def self.ransackable_attributes(auth_object = nil)
    %w[email sign_in_count created_at updated_at courses_count enrollments_count]
  end

  def username
    email.split("@").first
  end

  def to_s
    username
  end

  # roles
  rolify

  after_create :assign_default_role

  def assign_default_role
    if User.count ==1
      self.add_role(:admin)
      self.add_role(:teacher)
      self.add_role(:student)
    else
      self.add_role(:student) if self.roles.blank?
      self.add_role(:teacher)
    end
  end

  validate :must_have_a_role, on: :update

  extend FriendlyId
  friendly_id :email, use: :slugged

  def online?
    updated_at > 5.minutes.ago
  end

  def buy_course(course)
    self.enrollments.create!(course: course, price: course.price)
  end


  def view_lesson(lesson)
    user_lesson = user_lessons.find_or_create_by!(lesson: lesson)
    user_lesson.increment!(:impressions)
    user_lesson
  end

  private

  def must_have_a_role
    unless roles.exists?
      errors.add(:roles, "You must have at least one role")
    end
  end
end
