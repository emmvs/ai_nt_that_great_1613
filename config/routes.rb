Rails.application.routes.draw do
  resources :students
  resources :teachers
  root 'students#index'
end
