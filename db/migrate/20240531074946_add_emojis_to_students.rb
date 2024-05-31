class AddEmojisToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :emoji, :string
  end
end
