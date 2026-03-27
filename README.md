# The Fighters — Sistema de Gestão de Academia de Taekwondo

Sistema web para gerenciar alunos, turmas, horários, aulas e presenças de uma academia de taekwondo. A funcionalidade central é o **check-in via QR Code**: cada aula gera um código único que o aluno escaneia para registrar presença.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Backend | Ruby 3.4.8 · Rails 8.1.1 |
| Banco de dados | SQLite3 (dev e produção) |
| Frontend | Hotwire (Turbo + Stimulus) · CSS puro · Importmap |
| Auth | Devise |
| Jobs | Solid Queue + Solid Queue Cron |
| Assets | Propshaft |
| QR Code | rqrcode |
| Deploy | Kamal + Docker |

---

## Configuração do ambiente

### Pré-requisitos

- Ruby 3.4.8 (recomendado: gerenciar com [mise](https://mise.jdx.dev/) ou rbenv)
- SQLite3

### Instalação

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

### Variáveis de ambiente (opcionais)

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `AULAS_WINDOW_DAYS` | `30` | Janela de dias futuros para criação automática de aulas |
| `SOLID_QUEUE_IN_PUMA` | — | Roda jobs dentro do Puma em desenvolvimento |

Crie um arquivo `.env` na raiz para sobrescrever os valores.

---

## Domínio

```
User (Devise)
 ├─ has_one :aluno      → aluno vinculado a uma conta
 └─ has_one :professor  → professor vinculado a uma conta

Modalidade
 └─ has_many :turmas

Turma
 ├─ belongs_to :modalidade
 ├─ has_many :alunos (via turma_alunos — join table)
 └─ has_many :horarios
         └─ has_many :aulas         ← uma instância por dia do slot recorrente
                  └─ has_many :presencas
                                ├─ belongs_to :aluno
                                └─ belongs_to :aula
```

### Modelos principais

#### `Aula`
Representa uma aula concreta em uma data específica. Gerada automaticamente a partir dos `Horario`s.

```ruby
Aula::STATUS = { confirmada: 0, realizada: 1, cancelada: 2 }
```

- `code` — UUID único, gerado automaticamente no `before_validation`. É a chave usada no QR Code.
- `data` — data da aula (não datetime — o horário vem de `horario.hora_inicio`).
- Um `horario` só pode ter **uma** aula por `data` (validação de unicidade com escopo).

#### `Horario`
Define um slot recorrente (ex: toda terça-feira das 19h às 20h).

```ruby
Horario::DIAS_SEMANA = { domingo: 0, segunda: 1, terca: 2, quarta: 3, quinta: 4, sexta: 5, sabado: 6 }
```

Ao ser criado, dispara `AulasParaNovoHorarioJob` via `after_create_commit`.

#### `Presenca`
Registro de presença de um aluno em uma aula. Constraint de unicidade: um aluno só pode ter uma presença por aula.

#### `Professor`
Table name: **`professores`** (inflection customizada em `config/initializers/inflections.rb` para Rails usar `professor` como singular).

Sempre associado a um `User` com `role: :professor`. Criação gerenciada por `ProfessoresService` — nunca diretamente pelo model.

---

## Fluxo de Presenças (QR Code)

```
1. AulasRollingWindowJob  →  cria Aulas para os próximos 30 dias
2. Aula#code (UUID)       →  gera QR Code via rqrcode
3. Professor exibe QR     →  aulas/show.html.erb
4. Aluno escaneia         →  GET /presenca/:code/checkin
5. PresencasController#checkin  →  valida data, cria Presenca
```

O endpoint de checkin valida:
- QR Code existe (aula encontrada pelo `code`)
- O `current_user` tem um `Aluno` associado
- A data da aula é hoje

---

## Background Jobs

### `AulasRollingWindowJob`
**Quando:** Diariamente às 02:00 (configurado em `config/recurring.yml`).
Também disparado na inicialização do servidor (`config/initializers/aulas_startup.rb`).

**O que faz:**
1. Marca aulas passadas com status `confirmada` e `data < hoje` como `realizada`
2. Cria aulas para os próximos `AULAS_WINDOW_DAYS` dias (idempotente — não duplica)

### `AulasParaNovoHorarioJob`
**Quando:** Disparado automaticamente ao criar um `Horario` (callback `after_create_commit`).

**O que faz:** Cria aulas para o novo horário dentro da janela de dias futuros.

---

## Autenticação e Roles

Gerenciado pelo Devise. Login por `email`.

```ruby
User::ROLES = { user: 0, admin: 1, professor: 2 }
```

| Role | Acesso |
|------|--------|
| `admin` | Acesso total — CRUD de tudo, incluindo criar/remover professores |
| `professor` | CRUD de alunos, turmas, aulas e horários. Pode ver outros professores, mas não editá-los |
| `user` | Apenas check-in via QR Code (fase futura: painel do aluno) |

### Helpers de controle de acesso (`ApplicationController`)

```ruby
require_admin!               # redireciona se não for admin
require_admin_or_professor!  # redireciona se não for admin nem professor
```

---

## Serviços

### `AulasService`
Toda a lógica de geração automática de aulas. Usar apenas os métodos de classe.

```ruby
AulasService.ensure_aulas_for_next_days(30)  # janela rolling
AulasService.update_past_aulas_status        # marca aulas passadas
```

### `ProfessoresService`
Criação atômica de `Professor` + `User` com senha temporária aleatória.

```ruby
result = ProfessoresService.create(nome:, cpf:, email:, data_nascimento:)
result[:professor]  # instância salva
result[:password]   # senha gerada — mostrar uma única vez via flash[:temp_password]

ProfessoresService.reset_password(professor)  # retorna nova senha temporária
```

**Nunca criar professores diretamente pelo model.** Usar sempre o service para garantir a transação Professor + User.

---

## Frontend

### Design System

CSS puro em `app/assets/stylesheets/application.css`. **Sem Bootstrap, sem Tailwind.**

**Paleta (tokens CSS):**

```css
--color-bg:      #0F0F0F   /* fundo principal */
--color-yellow:  #F5C400   /* destaque / ações primárias */
--color-white:   #FFFFFF   /* cards e texto */
--color-red:     #C41E3A   /* ações destrutivas */
--color-border:  #2E2E2E   /* bordas */
--radius-lg:     12px
```

**Classes principais:**

| Categoria | Classes |
|-----------|---------|
| Layout | `.page`, `.page-header`, `.grid`, `.grid-6`, `.section` |
| Cards | `.card`, `.card-header`, `.nav-card`, `.nav-card--highlight` |
| Botões | `.btn`, `.btn-primary`, `.btn-danger`, `.btn-outline`, `.btn-ghost`, `.btn-sm` |
| Formulários | `.form-card`, `.form-dark`, `.form-group`, `.form-input`, `.form-grid`, `.form-actions` |
| Feedback | `.toast`, `.toast--success`, `.toast--error`, `.form-errors` |
| Auth | `.auth-layout`, `.auth-brand` |

### Hotwire

- **Turbo Streams** para presenças: `create` e `destroy` respondem com `turbo_stream` atualizando a lista e o contador sem reload de página.
- **Turbo Frames:** não usado extensivamente ainda — oportunidade para futuras features.

### Stimulus Controllers

| Controller | Arquivo | Função |
|------------|---------|--------|
| `confirm` | `confirm_controller.js` | Modal de confirmação substituindo `window.confirm()` |
| `toast` | `toast_controller.js` | Auto-dismiss de notificações (4 segundos) |
| `search` | `search_controller.js` | Filtro client-side por `data-nome` |

**Modal de confirmação:** `Turbo.config.forms.confirm` é sobrescrito em `application.js`. Todos os `data-turbo-confirm` da aplicação usam o modal automaticamente — sem precisar alterar as views. O botão usa `.btn-danger` para métodos DELETE e `.btn-primary` para os demais.

### Toasts (Notificações)

Para exibir um toast a partir de um controller Rails:

```ruby
redirect_to @turma, notice: "Turma criada com sucesso."       # toast verde
redirect_to turmas_path, alert: "Não foi possível excluir."   # toast vermelho
```

---

## Estrutura de arquivos relevantes

```
app/
├── controllers/
│   ├── application_controller.rb      # Auth global, require_admin!, layout switching
│   ├── presencas_controller.rb        # Check-in via QR Code (#checkin)
│   ├── aulas_controller.rb            # #cancel_aula, #confirm_aula
│   └── professores_controller.rb      # CRUD + #reset_password
├── models/
│   ├── aula.rb                        # STATUS enum, UUID, is_cancelada? etc.
│   ├── horario.rb                     # DIAS_SEMANA, after_create_commit
│   └── user.rb                        # ROLES, admin?, professor?, admin_or_professor?
├── services/
│   ├── aulas_service.rb               # Lógica de criação de aulas (rolling window)
│   └── professores_service.rb         # Criação atômica professor + user
├── jobs/
│   ├── aulas_rolling_window_job.rb    # Job diário (02:00)
│   └── aulas_para_novo_horario_job.rb # Disparado ao criar Horario
├── javascript/controllers/
│   ├── confirm_controller.js          # Modal de confirmação
│   ├── toast_controller.js            # Auto-dismiss toasts
│   └── search_controller.js          # Filtro client-side
└── assets/stylesheets/
    └── application.css                # Design system completo

config/
├── routes.rb                          # Todas as rotas
├── recurring.yml                      # Agenda do Solid Queue Cron
└── initializers/
    ├── aulas_startup.rb               # Dispara job ao subir o servidor
    └── inflections.rb                 # professor/professores (inflection custom)
```

---

## Convenções do projeto

- **Nomes em PT-BR:** `aluno`, `turma`, `aula`, `horario`, `presenca`, `modalidade`, `professor`
- **Controllers thin:** lógica de negócio vai nos models ou em `app/services/`
- **Status como enums inteiros:** constante `STATUS` no model, acesso por symbol (ex: `Aula::STATUS[:confirmada]`)
- **Transações em services:** criações que envolvem múltiplos records usam `ActiveRecord::Base.transaction`
- **Turbo Streams para feedback imediato:** presenças respondem com stream sem reload

---

## Comandos úteis

```bash
bin/rails server            # Inicia o servidor (porta 3000)
bin/rails db:migrate        # Roda migrations pendentes
bin/rails test              # Roda testes
bin/rails routes            # Lista todas as rotas
bin/rails console           # Console interativo
bin/brakeman                # Análise de segurança estática
bin/rubocop                 # Linting
```

---

## Deploy

O projeto usa **Kamal** com Docker. Configure `config/deploy.yml` com as credenciais do servidor antes do primeiro deploy.

```bash
kamal setup    # Primeiro deploy
kamal deploy   # Deploys subsequentes
```
