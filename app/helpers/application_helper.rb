module ApplicationHelper
  def format_cpf(cpf)
    cpf.to_s.gsub(/\D/, "").sub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
  end
end
