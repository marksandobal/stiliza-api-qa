class AddVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :verification_code, :string
    add_column :users, :verified, :boolean, default: false
    add_column :users, :verification_sent_at, :datetime
    add_column :users, :verified_at, :datetime
  end
end
