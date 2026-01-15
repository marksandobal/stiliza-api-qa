class AddUserProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_profiles do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :last_name, null: false
      t.string :second_last_name
      t.integer :gender, default:  0, null: false
      t.date :birth_date

      t.timestamps
    end
  end
end
