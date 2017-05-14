Rails.application.routes.draw do
  root "welcome#index"

  # get "/candidates", to: "candidates#index"
  # get "/candidates/:id", to: "candidates#show"

  # resources :candidates, path: "GG"
  resources :candidates # 慣例是複數
end
