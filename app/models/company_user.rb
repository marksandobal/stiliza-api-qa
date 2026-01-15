class CompanyUser < ApplicationRecord
  belongs_to :user
  belongs_to :company

  enum :role, {
    user: 0, coach: 1, admin: 2, super_admin: 3
  }

  validates :role, inclusion: { in: roles.keys }
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :company_id, message: "is already associated with this company." }
  validates :company_id, presence: true
end
