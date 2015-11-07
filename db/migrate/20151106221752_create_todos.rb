class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.text :title
      t.date :due
      t.string :state

      t.timestamps null: false
    end
  end
end
