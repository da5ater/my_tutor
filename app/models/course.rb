class Course < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  validates :title, :description, :short_description, :language, :level, :price, presence: true
  validates :description, length: { minimum: 50 }
  validates :level, inclusion: { in: [ "Beginner", "Intermediate", "Advanced" ] }
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :title, uniqueness: true

  def to_s
    title
  end

  has_rich_text :description
  belongs_to :user, counter_cache: true
  has_many :lessons, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at language level price short_description title lessons_count enrollments_count average_rating]
  end


  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  LANGUAGES = [ "English", "Arabic", "French" ]
  LEVELS = [ "Beginner", "Intermediate", "Advanced" ]

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
  include PublicActivity::Model
  tracked only: [ :create, :destroy ], owner: ->(controller, model) { controller&.current_user }

  before_save :check_description_changes
  after_update :track_update

  has_many :enrollments

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
