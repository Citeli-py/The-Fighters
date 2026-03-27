# The Fighters — Contexto do Projeto

## O que é este sistema

Sistema de gestão de academia de taekwondo. Gerencia alunos, turmas, horários, aulas e presenças.
A feature central é o **check-in via QR Code**: cada aula tem um UUID único; o aluno escaneia para registrar presença.

## Stack

- **Rails 8.1.1** | Ruby 3.4.8
- **Banco**: SQLite3 (desenvolvimento e produção)
- **Frontend**: Turbo Rails + Stimulus + Importmap (Hotwire stack)
- **Auth**: Devise (roles: admin, professor, user)
- **QR Code**: rqrcode gem
- **Background jobs**: Sidekiq + sidekiq-cron
- **Assets**: Propshaft
- **Deploy**: Kamal + Docker

## Domínio

```
User (Devise)
 ├─ has_one :aluno      → aluno pertence ao usuário com conta
 └─ has_one :professor  → professor pertence ao usuário com conta

Modalidade
 └─ has_many :turmas

Turma
 ├─ belongs_to :modalidade
 ├─ has_many :alunos (via turma_alunos)
 └─ has_many :horarios
         └─ has_many :aulas
                  └─ has_many :presencas
                                ├─ belongs_to :aluno
                                └─ belongs_to :aula
```

### Fluxo de Presença

1. `Horario` define dias/horários recorrentes de uma turma
2. `AulasService` cria `Aula` automaticamente (janela de 7 dias futuros)
3. Cada `Aula` tem `code` (UUID) → gera QR Code
4. Aluno escaneia → `GET /presenca/:code/checkin` → `Presenca` criada

### Status de Aulas

```ruby
Aula::STATUS = { confirmada: 0, realizada: 1, cancelada: 2 }
```

## Roles de Usuário

```ruby
User::ROLES = { user: 0, admin: 1 }
# TODO: adicionar role :professor (2)
```

## Convenções do Projeto

- **Nomes em PT-BR**: `aluno`, `turma`, `aula`, `horario`, `presenca`, `modalidade`
- **Controllers thin**: lógica de negócio nos models ou em services
- **Services**: `app/services/` para operações complexas (ex: `AulasService`)
- **Status como enums inteiros**: constante STATUS no model, acesso por symbol
- **before_action** para `set_*` e `require_admin!`
- **Validações** sempre na camada de model

## Design System (CSS)

Paleta: `#0F0F0F` (preto bg) · `#F5C400` (amarelo destaque) · `#FFFFFF` (branco cards)

Classes principais em `app/assets/stylesheets/application.css`:
- Layout: `.page`, `.page-header`, `.grid`, `.grid-6`, `.section`
- Cards: `.card`, `.card.destaque`, `.card-header`
- Botões: `.btn`, `.btn-primary`, `.btn-danger`, `.btn-outline`, `.btn-sm`
- Forms: `.form-card`, `.form-group`, `.form-input`, `.form-grid`, `.form-actions`
- Alertas: `.alert-success`, `.alert-failure`
- Domínio: `.turma-show`, `.turma-header`, `.turma-actions`

## Arquivos Críticos

| Arquivo | Função |
|---------|--------|
| `app/services/aulas_service.rb` | Criação automática de aulas (rolling window 7 dias) |
| `app/jobs/aulas_rolling_window_job.rb` | Job que chama AulasService |
| `app/controllers/presencas_controller.rb` | Check-in via QR Code |
| `app/controllers/application_controller.rb` | Auth global + `require_admin!` |
| `config/routes.rb` | Rotas da aplicação |
| `db/schema.rb` | Schema atual do banco |

## Bugs Conhecidos

1. **`alunos_controller.rb`**: `before_action :require_admin` (sem `!`) — não bloqueia não-admins
2. **`presencas_controller.rb#checkin`**: `aluno_id = 2` hardcoded — ignorar usuário logado
   - Fix: associar `Aluno` com `User` via `user_id` em `alunos`

## Modelagem Planejada (ainda não implementada)

- `alunos`: adicionar `user_id` (FK → users), `telefone`, `avatar_url`
- `users`: role `:professor` (value 2) a adicionar
- Model `Professor` separado (semelhante a `Aluno`)

## Roadmap (fora do escopo atual)

- Graduações (faixas)
- Eventos / competições
- Certificados
- Financeiro / mensalidades

## Comandos Úteis

```bash
bin/rails server          # Inicia o servidor
bin/rails db:migrate      # Roda migrations
bin/rails test            # Roda todos os testes
bin/rails routes          # Lista todas as rotas
bin/rails console         # Console Rails
```
