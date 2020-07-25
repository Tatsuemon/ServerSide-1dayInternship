class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.references :person, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :organization
      t.string :department
      t.string :title

      t.timestamps

      t.index :name
      t.index :email
      t.index :organization
    end
  end
end
