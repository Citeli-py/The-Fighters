# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_01_220546) do
  create_table "alunos", force: :cascade do |t|
    t.string "cpf"
    t.datetime "created_at", null: false
    t.date "data_nascimento"
    t.string "nome"
    t.datetime "updated_at", null: false
  end

  create_table "aulas", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.date "data"
    t.integer "horario_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["horario_id", "data"], name: "index_aulas_on_horario_id_and_data", unique: true
    t.index ["horario_id"], name: "index_aulas_on_horario_id"
  end

  create_table "horarios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dia_semana"
    t.time "hora_fim"
    t.time "hora_inicio"
    t.integer "turma_id", null: false
    t.datetime "updated_at", null: false
    t.index ["turma_id"], name: "index_horarios_on_turma_id"
  end

  create_table "modalidades", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome"
    t.datetime "updated_at", null: false
  end

  create_table "presencas", force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.integer "aula_id", null: false
    t.datetime "created_at", null: false
    t.boolean "presente"
    t.datetime "updated_at", null: false
    t.index ["aluno_id"], name: "index_presencas_on_aluno_id"
    t.index ["aula_id"], name: "index_presencas_on_aula_id"
  end

  create_table "turma_alunos", force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.datetime "created_at", null: false
    t.integer "turma_id", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id"], name: "index_turma_alunos_on_aluno_id"
    t.index ["turma_id"], name: "index_turma_alunos_on_turma_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descricao"
    t.integer "modalidade_id", null: false
    t.string "nome"
    t.datetime "updated_at", null: false
    t.index ["modalidade_id"], name: "index_turmas_on_modalidade_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "aulas", "horarios"
  add_foreign_key "horarios", "turmas"
  add_foreign_key "presencas", "alunos"
  add_foreign_key "presencas", "aulas"
  add_foreign_key "turma_alunos", "alunos"
  add_foreign_key "turma_alunos", "turmas"
  add_foreign_key "turmas", "modalidades"
end
