# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/machines')
  resources :machines
end
