class Course < ApplicationRecord
  extend FriendlyId
  include PublicActivity::Model
  friendly_id :title, use: :slugged

  validates :title, :description, :short_description, :language, :level, :price, presence: true
  validates :description, length: { minimum: 50 }
  validates :level, inclusion: { in: [ "Beginner", "Intermediate", "Advanced" ] }
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :title, uniqueness: true


  has_rich_text :description
  belongs_to :user, optional: true, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :user_lessons, through: :lessons
  has_many :enrollments, dependent: :restrict_with_error


  before_save :check_description_changes
  after_update :track_update

  tracked only: [ :create, :destroy ], owner: ->(controller, model) { controller&.current_user }


  scope :latest, -> { order(created_at: :desc).limit(3) }
  scope :popular, -> { order(enrollments_count: :desc, created_at: :desc).limit(3) }
  scope :top_rated, -> { order(average_rating: :desc, created_at: :desc).limit(3) }


  LANGUAGES = [ "English", "Arabic", "French" ]
  LEVELS = [ "Beginner", "Intermediate", "Advanced" ]

  def to_s
    title
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at language level price short_description title lessons_count enrollments_count average_rating]
  end


  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  def self.languages
    LANGUAGES.map do |language|
      [ language, language ]
    end
  end

  def self.levels
    LEVELS.map do |level|
      [ level, level ]
    end
  end

  # Track the course activities

  def bought?(user)
    return false unless user

    self.enrollments.where(user_id: user.id).exists?
  end

  def update_rating
    rated_enrollments = enrollments.where.not(rating: nil)
    if enrollments.any? && rated_enrollments.any?
      update_column :average_rating, rated_enrollments.average(:rating).round(2).to_f
    else
      update_column :average_rating, 0.0
    end
  end


  def progress_for(user)
    return 0.0 unless user

    lesson_count = lessons.count
    return 0.0 if lesson_count.zero?

    viewed_count = user_lessons.where(user_id: user.id).count

    (viewed_count.to_f / lesson_count) * 100.0
  end

  private

  def check_description_changes
    @description_changed = rich_text_description&.body_changed?
  end

  def track_update
    if saved_changes.any? || @description_changed
      create_activity :update, owner: PublicActivity.get_controller&.current_user
    end
  end
end
