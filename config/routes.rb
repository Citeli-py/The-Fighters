Rails.application.routes.draw do
  # Devise Routes
  devise_for :users# , skip: [ :registrations ]

  resources :horarios
  resources :modalidades
  resources :alunos

  resources :professores do
    member { patch :reset_password }
  end

  resource :perfil, only: %i[ edit update ], controller: "perfil"

  # Aulas Routes
  resources :aulas do
    resources :presencas, only: [ :create, :destroy ]
  end

  # PATCH /aulas/1/cancel
  patch "aulas/:id/cancel", to: "aulas#cancel_aula", as: "cancel_aula"
  # PATCH /aulas/1/confirm
  patch "aulas/:id/confirm", to: "aulas#confirm_aula", as: "confirm_aula"

  resources :turmas do
    resources :turma_alunos, only: [ :new, :create, :destroy ]
  end


  get "/presenca/:code/checkin", to: "presencas#checkin", as: "presenca_checkin"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
