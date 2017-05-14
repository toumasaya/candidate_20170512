Rails.application.routes.draw do
  root "welcome#index"

  # get "/candidates", to: "candidates#index"
  # get "/candidates/:id", to: "candidates#show"

  # resources :candidates, path: "GG"
  resources :candidates do # 慣例是複數
    # collection do
    #   post :vote
    # end

    member do
      post :vote
    end

    # post :vote, on: :member
  end
  # post "/candidate/:id/vote", to: "candidate#vote"
end
