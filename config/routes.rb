Rails.application.routes.draw do
  namespace :api, :path => "", :defaults => {:format => :json} do
    namespace :v1 do
      resources :cards
      resources :decks
    end
  end
end
# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
