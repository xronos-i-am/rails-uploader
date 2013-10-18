Uploader::Engine.routes.draw do
  resources :attachments, :only => [:create, :destroy] do
    collection do
      post :sort
    end
  end
end
