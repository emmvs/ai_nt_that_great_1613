class AddNicknamesToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :nickname, :string
  end
end
