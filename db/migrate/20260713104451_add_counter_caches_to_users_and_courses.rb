class AddCounterCachesToUsersAndCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :courses_count, :integer, default: 0, null: false
    add_column :users, :enrollments_count, :integer, default: 0, null: false
    add_column :courses, :lessons_count, :integer, default: 0, null: false
  end
end
