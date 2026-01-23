class AddStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :studios do |t|
      t.string :name, null: false
      t.string :description
      t.string :handle, null: false
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :studios, :handle, unique: true
  end
end
