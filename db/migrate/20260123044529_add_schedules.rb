class AddSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :branch, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :schedules, [:branch_id, :day_of_week, :start_time, :end_time], unique: true
  end
end
