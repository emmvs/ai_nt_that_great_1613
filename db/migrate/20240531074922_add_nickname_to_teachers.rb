class AddNicknameToTeachers < ActiveRecord::Migration[7.1]
  def change
    add_column :teachers, :nickname, :string
  end
end
