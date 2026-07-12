class AddEnrollmentsCountToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :enrollments_count, :integer, default: 0, null: false
  end
end
