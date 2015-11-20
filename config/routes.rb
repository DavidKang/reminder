Rails.application.routes.draw do
  root to: 'todos#index'

  resources :todos
  post 'todo/:id/done', to: 'todos#done'
  post 'todo/:id/reopen', to: 'todos#reopen'
end
