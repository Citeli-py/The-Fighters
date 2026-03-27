class ProfessoresService
  # Cria professor + user com senha aleatória.
  # Retorna { professor:, password: } em caso de sucesso.
  # Levanta ActiveRecord::RecordInvalid se algo falhar (transação revertida).
  def self.create(nome:, cpf:, data_nascimento: nil)
    password = SecureRandom.alphanumeric(10)
    username = cpf.gsub(/\D/, "") # apenas dígitos do CPF

    ActiveRecord::Base.transaction do
      user = User.create!(
        username: username,
        email:    "#{username}@thefighters.local",
        password: password,
        password_confirmation: password,
        role: User::ROLES[:professor]
      )

      professor = Professor.create!(
        nome:            nome,
        cpf:             cpf,
        data_nascimento: data_nascimento,
        user:            user
      )

      { professor: professor, password: password }
    end
  end

  # Reseta a senha de um professor existente.
  # Retorna a nova senha temporária.
  def self.reset_password(professor)
    password = SecureRandom.alphanumeric(10)
    professor.user.update!(
      password: password,
      password_confirmation: password
    )
    password
  end
end
