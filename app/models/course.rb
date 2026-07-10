class Course < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  validates :title, :description, :short_description, :language, :level, :price, presence: true
  validates :description, length: { minimum: 50 }
  validates :level, inclusion: { in: [ "Beginner", "Intermediate", "Advanced" ] }
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }


  def to_s
    title
  end

  has_rich_text :description

  belongs_to :user
end
