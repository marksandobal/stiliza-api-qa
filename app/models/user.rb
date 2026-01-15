class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :validatable,
         :lockable,
         :trackable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_one :user_profile, dependent: :destroy
  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  # Esto permite que Devise reciba los datos de user_profile directamente en el los strong params
  accepts_nested_attributes_for :user_profile

  before_create :generate_verification_code
  after_update :handle_security_updates, if: :saved_change_to_encrypted_password?

  validates :email, presence: true, uniqueness: true

  VERIFICATION_EXPIRATION = 10.minutes

  def generate_verification_code
    self.verification_code = rand.to_s[2..7] # código de 6 dígitos
    self.verification_sent_at = Time.current
    self.verified = false
  end

  def verification_code_valid?
    verification_sent_at && verification_sent_at > VERIFICATION_EXPIRATION.ago
  end

  def mark_as_verified!
    update!(verified: true, verification_code: nil, verified_at: Time.current)
  end

  def jwt_subject
    "#{id}-#{updated_at.to_i}"
  end

  def active_for_authentication?
    # Llamamos a super para mantener las validaciones de Devise (como lockable o confirmable)
    # y añadimos nuestra lógica de verified
    super && verified?
  end

  private

  def handle_security_updates
    invalidate_jwt
    UserMailer.password_changed(self).deliver_later
  end



  def invalidate_jwt
    update_column(:updated_at, Time.current)
  end
end
