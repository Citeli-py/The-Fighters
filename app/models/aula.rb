class Aula < ApplicationRecord
  belongs_to :horario

  has_many :presencas, dependent: :restrict_with_error


  STATUS = {
    confirmada: 0,
    realizada:  1,
    cancelada:  2
  }

  before_validation :generate_code, on: :create

  validates :code, presence: true, uniqueness: true
  validates :status, :data, presence: true

  validates :horario_id, uniqueness: {
    scope: :data,
    message: "já possui aula cadastrada para este dia"
  }

  def status_nome
    STATUS.key(status)&.to_s&.humanize
  end

  def data_hora_formatada
    dia = data.strftime("%d/%m/%Y")

    inicio = horario.hora_inicio.strftime("%H:%M")
    fim    = horario.hora_fim.strftime("%H:%M")

    "#{dia} | #{inicio} - #{fim}"
  end

  def confirm!
    update!(status: STATUS[:confirmada])
  end

  def cancel!
    update!(status: STATUS[:cancelada])
  end

  def update_status(status)
    update!(status: STATUS[status.to_sym])
  end

  def is_passada?
    data < Date.current
  end

  def is_confirmada
    status == STATUS[:confirmada]
  end

  def is_realizada
    status == STATUS[:realizada]
  end

  def is_cancelada
    status == STATUS[:cancelada]
  end


  private

  def generate_code
    self.code ||= SecureRandom.uuid
  end
end
