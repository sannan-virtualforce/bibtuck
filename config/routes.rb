Bibtuck::Application.routes.draw do

#  resources :subscribers, :only => [ :new, :create, :show ]

  match 'vogue' => 'subscribers#new', :as => :new_subscriber
  match 'vogue/signup' => 'subscribers#create', :as => :subscribers
  match 'vogue/thank-you' => 'subscribers#show', :as => :subscriber

  root :to => "home#index"
  match 'splash' => 'home#splash', :as => :splash

  get "users/index"

  resources :feedback_messages
  resources :photos do
    member do
      post :aviary_callback
    end
  end

  resources :brands
  resources :items do
    resources :buck_refunds do
      get :accept, :on => :member
      get :reject, :on => :member
      get :thank_you, :on => :member
    end
    resources :carrier_pickups
    resources :flagged_items
    member do
      get :extended_state
      get :shipping_label
      put :bib
      put :unbib
      get :quick_view
    end
  end

  resources :authentications
  match '/auth/:provider/callback' => 'authentications#create'

  devise_for :users, :controllers => {
                        :invitations   => 'invitations',
                        :registrations => 'registrations',
                        :sessions      => 'sessions'
                      }

  post 'admin/search'
  post '/search' => 'search#create'

  resources :conversations, :controller => "user_conversations" do
    resources :messages
    member do
      post :mark_as_read
      post :mark_as_unread
    end
    collection do
      post :bulk_update
    end
  end

  resources :users do
    resources :conversations, :controller => "user_conversations"
    post :resend_invite, :on => :member
    post :destroy_saved_photos, :on => :collection
    resources :addresses do
      get :set_as_primary, :on => :member
    end
    resources :experiences do
      get :thank_you, :on => :collection
    end
    member do
      get :activity
      get :account
      get :bucks
      get :saved_photos
      get :deactivate
      get :featured
      get :edit_email
      get :edit_username
      get :edit_password
      put :update_field
      put :update_password
      get :autocomplete_field_results
      get :request_shipping_boxes
      post :post_shipping_boxes_request
    end
    resources :follows, :only => [ :index ], :path => 'friends'
  end

  match '/admin' => 'admin#index'
  match 'export_orders' =>  'admin#export_orders', :as => :export_orders
  match 'export_items' =>  'admin#export_items', :as => :export_items
  match 'export_users' =>  'admin#export_users', :as => :export_users

  namespace :admin do
    resources :photos
    resources :discounts
    resources :credits
    resources :featured_closets do
      member do
        get :set_current
      end
    end
    resources :lookbook_photos
    resources :subscribers do
      get :export, :on => :collection
    end
    resources :users do
      member do
        get :activate
        get :deactivate_popup
        post :deactivate
      end
    end
    resources :brands
    resources :items do
      member do
        get :change_state
      end
    end
    resources :messages
    resources :flagged_items
    resources :registration_codes
    resources :recommendations
    resources :parameters
    resources :orders do
      member do
        get :edit_address
        post :update_address
      end
    end
    resources :shipping_boxes do
      member do
        post :set_amounts
      end
    end
  end

  resources :carts
  resources :orders do
    member do
      get :express
      get :setaddress
      get :complete
      get :wepayauth
    end
  end
  resources :signups
  resources :buck_purchases do
    collection do
      get :express
      get :complete
      get :not_enough
      get :select_payment_option
    end
  end

  resources :notifications do
    collection do
      post :mark_as_read
    end
  end
  resources :follows, :only => [ :create, :destroy ]
  resources :pages

  %w(
    about
    contact_us
    how_it_works
    q_and_a
    legal_stuff
    shipping_and_transaction_info
    shipping_from_info
    shipping_box_info
    community_guidelines
    photo_tips
  ).each { |path|
    match "pages/#{path.gsub('_','-')}" => 'high_voltage/pages#show',
          :id => path
  }
  
  match '*a', :to => 'errors#routing'

end
