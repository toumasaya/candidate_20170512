Rails.application.routes.draw do
  root "welcome#index"

  resources :candidates do # 慣例是複數
    member do
      post :vote
    end
  end
end
