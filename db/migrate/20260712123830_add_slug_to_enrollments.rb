class AddSlugToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :slug, :string
    add_index :enrollments, :slug, unique: true
  end
end
