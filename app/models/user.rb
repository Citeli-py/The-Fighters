class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_one :aluno
  has_one :professor

  ROLES = {
    user: 0,
    admin: 1,
    professor: 2
  }

  def get_role
    ROLES.key(self.role)
  end

  def admin?
    self.role == ROLES[:admin]
  end

  def professor?
    self.role == ROLES[:professor]
  end

  def admin_or_professor?
    admin? || professor?
  end

end
