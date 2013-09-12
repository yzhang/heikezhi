Hkz::Application.routes.draw do
  devise_for :users, :skip => [:sessions], :controllers => {:passwords => 'account/passwords', :confirmations => 'devise/confirmations'}
  devise_scope :user do
    scope :module => 'account' do
      get   "signin",    :to => "sessions#new",    :as => 'new_user_session'
      post  "signin",    :to => "sessions#create", :as => 'user_session'
      get   "signout",   :to => "sessions#destroy"

      get   "forgot_password", :to => "sessions#forgot_password"
      post  "forgot_password", :to => "sessions#send_reset_instruction"

      get   "signup",       :to => "registrations#new"
      post  "signup",       :to => "registrations#create"

      get   "profile/edit", :to => "profile#edit", :as => :edit_profile
      put   "profile",      :to => "profile#update", :as => :update_profile

      get   "settings", :to => "users#edit"
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get  '/page/:page' => 'articles#index'
  get  '/atom'   => 'articles#index', defaults: {format: 'atom'}
  get  '/articles' => 'articles#index'
  root :to => 'articles#index'

  resources :images

  get    '/mine(.:format)'   => 'articles#mine'
  get    '/mine/:permalink(/)' => 'articles#mine', as: :mine_article
  get    '/articles/new' => 'articles#new', as: :new_article
  delete '/delete/:permalink(/)' => 'articles#destroy', as: :delete_article
  put    '/mine/:permalink(/)' => 'articles#update', as: :update_article
  put    '/publish/:permalink(/)' => 'articles#publish', as: :publish_article
  get    '/edit/:permalink(/)' => 'articles#edit', as: :edit_article

  get  '/:name/atom'  => 'articles#user', defaults: {format: 'atom'}
  get  '/:name/:permalink(/)' => 'articles#show', :as => :article_permalink

  get  '/:name'  => 'articles#user', :as => :user
end
