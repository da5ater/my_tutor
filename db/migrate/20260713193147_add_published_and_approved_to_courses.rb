class AddPublishedAndApprovedToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :published, :boolean, default: false, null: false
    add_column :courses, :approved, :boolean, default: false, null: false
  end
end
