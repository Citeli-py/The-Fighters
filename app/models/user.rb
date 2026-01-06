class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = {
    user: 0,
    admin: 1
  }

  def get_role
    ROLES.key(self.role)
  end

  def admin?
    self.role == ROLES[:admin]
  end
end
