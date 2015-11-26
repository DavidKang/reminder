class AddMoreAttrToTodo < ActiveRecord::Migration
  def change
    add_column :todos, :to, :string
    add_column :todos, :at, :integer
  end
end
