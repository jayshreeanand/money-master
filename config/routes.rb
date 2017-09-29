Rails.application.routes.draw do

  devise_for :users
  
  get '/' => 'pages#home'
  get '/truelayer' => 'truelayer#authenticate'
  get '/truelayer/callback' => 'truelayer#callback'
  get '/truelayer/access_token_callback' => 'truelayer#access_token_callback'

  get '/starling_bank' => 'starling_bank#authenticate'
  get '/starling_bank/callback' => 'starling_bank#callback'


  get 'connect' => 'bank_accounts#connect'
  get '/bank_accounts/sync' => 'bank_accounts#sync'

  resources :bank_accounts
end
