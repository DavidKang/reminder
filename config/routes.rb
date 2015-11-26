Rails.application.routes.draw do
  root to: 'todos#index'

  resources :todos
  post 'todos', to: 'todos#index'
  post 'todo/:id/done', to: 'todos#done'
  post 'todo/:id/reopen', to: 'todos#reopen'
  post 'todos/import', to: 'todos#import'
  get 'done_todos', to: 'todos#done_todos'
end
