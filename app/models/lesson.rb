class Lesson < ApplicationRecord
  belongs_to :course, counter_cache: true

  validates :title, :content, :course, presence: true

  has_rich_text :content


  extend FriendlyId
  friendly_id :title, use: :slugged

  def to_s
    title
  end

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user }
end
