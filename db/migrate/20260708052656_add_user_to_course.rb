class AddUserToCourse < ActiveRecord::Migration[8.1]
  def change
    add_reference :courses, :user, null: false, foreign_key: true
  end
end
