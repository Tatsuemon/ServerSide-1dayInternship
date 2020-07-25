Rails.application.routes.draw do
  root 'people#index'

  resources :people, only: %i[index] do
    collection do
      put :merge
    end
  end
  resources :cards, only: %i[show]
end
