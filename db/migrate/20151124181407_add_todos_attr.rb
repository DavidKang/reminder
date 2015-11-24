class AddTodosAttr < ActiveRecord::Migration
  def change
    add_column :todos, :project, :string
  end
end
