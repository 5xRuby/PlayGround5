# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root to: redirect('/machines')
  resources :machines, only: %i[index show] do
    member do
      put :hold
      put :release
    end
  end
end
