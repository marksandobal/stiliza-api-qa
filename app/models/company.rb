class Company < ApplicationRecord
  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :studios, dependent: :destroy

  validates :name, presence: true
end
