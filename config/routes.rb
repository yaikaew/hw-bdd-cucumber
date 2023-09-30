Rottenpotatoes::Application.routes.draw do
  resources :movies do
    resources :reviews
  end
  
  resources :moviegoers do
    resources :reviews
  end
  
  devise_for :moviegoers, controllers: {
    omniauth_callbacks: 'moviegoers/omniauth_callbacks',
    sessions: 'moviegoers/sessions',
    registrations: 'moviegoers/registrations'
    }
    
  # map '/' to be a redirect to '/movies'
  root :to => redirect('/movies')
  post '/movies/search_tmdb' => 'movies#search_tmdb', :as => 'search_tmdb'
end
