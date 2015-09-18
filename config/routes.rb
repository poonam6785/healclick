Healclick::Application.routes.draw do

  get '/treatments/:treatment_summary_id', to: redirect('/treatments/%{treatment_summary_id}/reviews')
  get '/doctors/:doctor_summary_id', to: redirect('/doctors/%{doctor_summary_id}/reviews')

  Redirect.all.each do |redir|
    get redir.from, to: redirect(redir.to)
  end
  post 'questionnaire/save_categories'
  post 'questionnaire/next_question'
  mount_roboto
  get 'system_settings/create'
  get 'system_settings/update'
  put 'system_settings/points_save'
  get 'time_series_analysis', to: 'users#time_series_analysis'
  get 'time_series_analysis_admin', to: 'users#time_series_analysis_admin'
  get 'main', to: 'home#index', post_type: 'any', as: 'everything'
  get 'topics', to: 'home#index', post_type: 'all_topics'
  get 'medical-topics', to: 'home#index', post_type: 'medical_topics', as: 'medical_topics'
  get 'social-topics', to: 'home#index', post_type: 'social_topics', as: 'social_topics'
  get 'fun-stuff', to: 'home#index', post_type: 'fun_stuff', as: 'fun_stuff'
  get 'introductions', to: 'home#index', post_type: 'introductions'
  get 'faq', to: 'home#index', post_type: 'faq'
  get 'blog', to: 'home#index', post_type: 'blog'
  get 'conditions/autocomplete', to: 'conditions#autocomplete'
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users, path_names: {sign_in: 'login', sign_out: 'logout' }, controllers: {omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }

  resources :posts do
    get :post_body, on: :member
    get :mark_as_helpful, on: :member
    get :follow, on: :member
    get :unfollow, on: :member
    get :luv, on: :member
    get :say_something, on: :collection
    get :expand_replies, on: :member
    resources :comments do
      resources :comments
      get :mark_as_helpful, on: :member
      get :luv, on: :member
    end
  end

  resources :noindex_rules, only: [:create, :destroy]

  resources :comments do
    get :mark_as_helpful, on: :member
    get :luv, on: :member
  end

  get '/reviews/summary', to: redirect('/treatments')
  resources :reviews do
    get :interest, on: :member
  end
  get '/treatments', to: 'reviews#summary', as: :summary_reviews

  resources :notifications do 
    get :read, on: :member
    get :mark_all_as_read, on: :collection
    delete :delete_all, on: :collection
  end

  resources :messages do 
    get :sent, on: :collection
    get :mark_all_as_read, on: :collection
    delete :delete_all, on: :collection
    delete :delete_all_sent, on: :collection
  end

  resources :users do 
    get :autocomplete, :on => :collection
    get :favorited_me, on: :member
    get :my_favorites, on: :member
    get :follow, on: :member
    get :unfollow, on: :member
    get :luv, on: :member
    get :leaderboard, on: :collection
    get :ranking, on: :collection
    get :favorite_list, on: :collection
    resources :photos do
      get :set_as_profile, on: :member    
      resources :comments
    end
    get :map, on: :collection
  end

  resources :photos do
    get :set_as_profile, on: :member
    resources :comments
  end

  resources :user_conditions

  resources :symptoms do 
    get :autocomplete, :on => :collection
    get :set_level, on: :member
    get :set_period, on: :member
    post :batch_create, on: :collection
    patch :batch_update, on: :collection
    post :popular_symptoms, on: :collection
    delete :batch_delete, on: :collection
  end

  resources :treatments do 
    get :autocomplete, :on => :collection
    get :set_level, on: :member
    get :set_period, on: :member
    put :set_type, on: :member
    resources :treatment_reviews
    post :batch_create, on: :collection
    patch :batch_update, on: :collection
    delete :batch_delete, on: :collection
  end

  resources :doctors do
    get :autocomplete, on: :collection
    post :batch_create, on: :collection
  end

  resources :treatment_reviews do
    get :autocomplete, :on => :collection
    get :check_unique_name, on: :collection
  end
  resources :doctor_reviews do
    # get :summary, on: :collection
    get :check_unique_name, on: :collection
  end


  get '/treatments/:treatment_summary_id/reviews/:id', to: 'posts#show', as: :treatment_summary_review
  get '/treatments/:treatment_summary_id/reviews', to: 'reviews#index', as: :treatment_summary_reviews
  get '/doctors/:doctor_summary_id/reviews/:id', to: 'posts#show', as: :doctor_summary_review_path
  get '/doctors/:doctor_summary_id/reviews', to: 'doctor_reviews#summary', as: :summary_doctor_reviews
  get '/treatment_summaries/:treatment_summary_id/reviews', to: 'reviews#old_routes', as: :old_routes

  resource :tracker, controller: :tracker do
    get :treatments, on: :collection
    get :symptoms, on: :collection
    get :well_being, on: :collection
  end

  get '/profile/:username', to: 'personal_profiles#show', as: :profile, constraints: {username: /.*/}

  get '/activity/:username', to: 'personal_profiles#activity', as: :activity, constraints: {username: /.*/}

  resource :personal_profile do
    get :select_main_condition, on: :member
    get :basic_info, on: :member
    get :my_health, on: :member
    get :profile_photo, on: :member
    get :symptoms, on: :member
    get :treatments, on: :member
    get :crop_photo, on: :member
    get :bookmarks, on: :member
    get :my_topics, on: :member
    get :symptoms_chart, on: :member
    patch :crop_photo, on: :member
  end

  resources :labs, only: [:update] do
    get :autocomplete, on: :collection
    get :change_date, on: :collection
    delete :batch_delete, on: :collection
    post :batch_create, on: :collection
  end

  resources :events, :only => [:update, :create, :show, :index]

  get 'settings', to: 'settings#index', as: :settings
  patch 'settings', to: 'settings#index', as: :post_settings

  post 'settings/set', to: 'settings#set', as: 'set_setting'

  resources :system_settings

  get 'home', to: 'home#new_home', as: :home
  get 'guest_sidebar', to: 'home#guest_sidebar'

  get 'skip_to_dashboard', to: 'home#skip', as: :skip_to_dashboard

  get 'my_click', to: 'my_click#index', as: :my_click
  get 'conditions/:condition_id', to: 'home#index', as: :conditions

  get 'landing', to: 'main#index', as: :landing
  get 'run_digest', to: 'main#run_digest'
  
  root to: 'home#new_home'

  # Error
  get '404', to: 'errors#index_404'
  get '500', to: 'errors#index_500'
end

RailsAdmin::Engine.routes.draw do
  get 'noindex_rules/destroy'
  get 'noindex_rules/create'
  get 'questionnaire/save_categories'
  get 'questionnaire/next_question'
  mount_roboto
  controller 'main' do
    scope ':model_name' do
      post 'bulk_edit_reviews', :to => :bulk_edit_reviews, :as => 'bulk_edit_reviews'
      post 'bulk_edit_treatments', :to => :bulk_edit_treatments, :as => 'bulk_edit_treatments'

      # Merge Treatment Summaries
      post 'bulk_edit_treatment_summaries', :to => :bulk_edit_treatment_summaries, :as => 'bulk_edit_treatment_summaries'
      get 'bulk_edit_treatment_summaries', :to => :get_bulk_edit_treatment_summaries, :as => 'get_bulk_edit_treatment_summaries'

      # Merge Symptoms Summaries
      post 'bulk_merge_symptom_summaries', :to => :bulk_merge_symptom_summaries, :as => 'bulk_merge_symptom_summaries'
      get 'bulk_merge_symptom_summaries', :to => :get_bulk_merge_symptom_summaries, :as => 'get_bulk_merge_symptom_summaries'
    end
  end
end
