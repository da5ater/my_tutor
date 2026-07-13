class Lesson < ApplicationRecord
  belongs_to :course, counter_cache: true

  validates :title, :content, :course, presence: true

  has_rich_text :content
  has_many :user_lessons, dependent: :destroy
  has_many :viewers, through: :user_lessons, source: :user

  extend FriendlyId
  friendly_id :title, use: :slugged

  def to_s
    title
  end


  def viewed_by?(user)
    user.present? && user_lessons.where(user_id: user.id).exists?
  end


  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user }
end
