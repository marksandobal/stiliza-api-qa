class AddDigitalChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :digital_channels do |t|
      t.integer :channel_type, null: false
      t.string :value, null: false
      t.references :studio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
