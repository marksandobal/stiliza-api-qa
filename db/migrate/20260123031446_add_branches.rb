class AddBranches < ActiveRecord::Migration[8.1]
  def change
    create_table :branches do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.string :timezone
      t.boolean :active, default: true
      t.references :studio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
