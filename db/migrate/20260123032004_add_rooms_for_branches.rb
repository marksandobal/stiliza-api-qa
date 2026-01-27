class AddRoomsForBranches < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.integer :capacity, null: false
      t.jsonb :layout, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.references :branch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
