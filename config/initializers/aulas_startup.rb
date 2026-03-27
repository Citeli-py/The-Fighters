Rails.application.config.after_initialize do
  # Roda o job de aulas apenas uma vez na inicialização do servidor,
  # evitando execução duplicada em reloads do development.
  next unless defined?(Rails::Server) || (Rails.env.production? && $PROGRAM_NAME.include?("puma"))

  Rails.logger.info "[AulasStartup] Enfileirando AulasRollingWindowJob na inicialização..."
  AulasRollingWindowJob.perform_later
end
