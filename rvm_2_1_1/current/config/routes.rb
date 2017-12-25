InquirlyNew::Application.routes.draw do

  #### Landing Page and Auth Routes ####

  devise_scope :user do
    authenticated :user do
      root 'application#home', as: :authenticated_root
    end

    unauthenticated :user do
      root  'home#index'
    end
  end
  
  devise_for :users, :controllers => {sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords", omniauth_callbacks: "users/omniauth_callbacks", confirmations: "users/confirmations", unlocks: "users/unlocks"}, :path_names => {sign_in: "login", sign_up: "register"}

  devise_scope :user do
    match "/users/auth/facebook/callback", :to => "users/omniauth_callbacks#facebook", via: :get
    match '/users/auth/twitter/callback' => "users/omniauth_callbacks#twitter", via: :get
    match '/users/auth/google_oauth2/callback' => "users/omniauth_callbacks#google", via: :get
    match '/users/auth/linkedin/callback' => "users/omniauth_callbacks#linkedin", via: :get
    match 'auth/:provider/failure', :to => "users/omniauth_callbacks#failure", via: :get
    match '/users/confirmation', :to => "users/confirmations#create", :via => :post
    match '/users/confirmation/new', :to => "users/confirmations#new", :via => :get
    match '/users/confirmation', :to => "users/confirmations#show", :via => :get
    match '/users/validate_user', :to => "users/sessions#validate_user_data", :via => :post
    match '/users/fb_pages', :to => "users/omniauth_callbacks#fb_pages", :via => :get
    match '/users/save_fb_pages', :to => "users/omniauth_callbacks#save_fb_pages", :via => :post
    match '/users/remove_fb_session', :to => "users/omniauth_callbacks#remove_fb_session", :via => :get
    match '/users/linkedin_pages', :to => "users/omniauth_callbacks#linkedin_pages", :via => :get
    match '/users/save_linkedin_pages', :to => "users/omniauth_callbacks#save_linkedin_pages", :via => :post
    match '/users/remove_linkedin_session', :to => "users/omniauth_callbacks#remove_linkedin_session", :via => :get
  end

  resources :home do
    collection do
      get 'signup', to: 'home#signup_form'
      get 'signin', to: 'home#signin_form'
      get 'forgot_password', to: 'home#forgot_password_form'
      post 'save_referrer'
      post 'fetch_short_url'
    end
  end

  get '/signup' => 'home#signup_form'
  get '/shorten_link' => 'home#shorten_link'

  #### Admin Login Routes ####

  namespace :admin do
    resources :pricing_plans
    resources :permissions
    resources :action_lists
    resources :client_settings do
      collection do
        get 'user_client_settings'
      end
    end
    resources :users, controller: "manage_users" do
      collection do
        post 'change_status'
      end
    end
    resources :manage_clients do
      collection do
        get 'plan_settings'
        get 'client_plan_details'
        post 'change_client_status'
        post 'save_client'
        post 'save_client_company'
        post 'save_client_pricing_plan'
        get 'client_signup'
        post 'update_client_company'
      end
      get 'show_users'
      get 'show_tenants'
      get 'edit_tenant'
      put 'update_tenant'
      get 'download_client_detail'
    end
  end
  match 'admin/manage_clients/:client_id/client_company', :to => "admin/manage_clients#client_company", via: :get
  match 'admin/manage_clients/:client_id/client_pricing_plan', :to => "admin/manage_clients#client_pricing_plan", via: :get

  resources :payments do
    collection do
      post 'update_payment_details'
      get 'get_user_emails'
    end
  end

  #### EMail and SMS Blast API Routes ####

  namespace :api do
    resources :campaigns do
      collection do
        post 'email_blast'
        post 'sms_blast'
      end
    end
  end

  resources :manage_roles do
    collection do
      post 'update_permissions'
      get 'role_permissions'
    end
  end

  #### Mobile API Routes ####

  namespace :rest do
    devise_for :session do
      post '/authenticate',  to:'sessions#create'
    end
    match '/getConfigData', to: 'power_share#social_accounts', as: :social_accounts, via: :post
    match '/powerShare', to: 'power_share#power_share', as: :power_share, via: :post
    match '/getShareQueue', to: 'power_share#get_share_queue', as: :get_share_queue, via: :post
    match '/getShareHistory', to: 'power_share#get_share_history', as: :get_share_history, via: :post
    match '/getReachData', to: 'power_share#get_reach_data', as: :get_reach_data, via: :post
    match '/deletePost', to: 'power_share#delete_post', as: :delete_post, via: :post
    match '/reschedulePost', to: 'power_share#reschedule_post', as: :reschedule_post, via: :post
    match '/getS3Config', to: 'power_share#get_s3_config', as: :get_s3_config, via: :post
    match '/getRecipients', to: 'power_share#get_recipients', as: :get_recipients, via: :post
    match '/getCampaigns', to: 'power_share#get_campaigns', as: :get_campaigns, via: :post
    match '/getSessionInfo', to: 'power_share#get_session_info', as: :get_session_info, via: :post
    match '/updateCampaignState', to: 'power_share#update_campaign_state', as: :update_campaign_state, via: :post
    match '/getApprovalPost', to: 'power_share#get_approval_post', as: :get_approval_post, via: :post
  end

  ##### Angular Routes ####

  resources :configurations do
    collection do
      get 'social_configure'
      post 'customise_campaign'
      get 'get_campaign_styles'
      get 'get_user_actions'
      get 'beacons_list'
      post 'create_beacon'
      post 'update_beacon'
      post 'change_status'
      get 'qr_code_list'
      post 'create_qr_code'
      post 'update_qr_code'
      get 'download_qr_code'
      post 'change_qr_status'
      get 'get_schedule_types'
      post 'add_slot'
      post 'remove_slot'
      post 'update_active_days'
      post 'update_schedule'
      post 'save_schedule'
      post 'pricing_plan_configure'
    end
  end

  resources :companies do
    collection do
      get 'get_tags'
      post 'get_company_info'
    end
  end

  resources :account do
    collection do
      get 'payment_details'
      get 'user_settings'
      post 'update_password'
      post 'update_user_details'
      post 'upload_profile_image'
      post 'destroy_profile_image'
      get  'user_details'
      post  'invite_user'
      get 'user_permissions'
    end
  end

  resources :tenants do
    collection do
      post 'change_tenant_status'
      get 'check_caller_id'
      get 'check_verify_caller_ids'
      get 'load_geo_details'
      post 'create_tenant'
      post 'create_region'
      post 'create_type'
      get 'get_client_plan'
      post 'save_tenant_plan'
      get 'get_tenant_plan'
    end
  end

  resources :corporate_users do
    collection do
      get 'mapping_roles'
      post 'update_user_roles'
      post 'reset_password'
      post 'change_user_status'
      post 'create_user'
      post 'reset_user_password'
      get 'load_regions'
      get 'load_tenants'
    end
  end

  resources :inq_campaigns do
    collection do
      get 'user_channels'
      post 'update_campaign_state'
    end
  end
  
  resources :power_share do
    collection do
     get 'social_accounts'
     post 'fetch_meta_data'
     post 'share_content'
     get 'scheduled_campaigns'
     post 'reschedule_share'
     post 'remove_post'
     get 'power_share_history'
     post 'get_reach'
     post 'archive_post'
     post 'campaign_share'
     post 'remove_schedule'
     post 'get_campaign_channels'
     post 'post_info'
    end
  end

  resources :customers do
    collection do
      get 'get_customer_email'
      get 'email_duplication_check'
      get 'mobile_duplication_check'
      post 'delete_selected'
      post 'remove_social_account'
      get 'all_countries'
      get 'states'
      post 'update_config'
      post 'update_group_info'
      get 'contact_groups'
      get 'group_customers'
      post 'update_group_name'
      post 'remove_group'
      post 'remove_group_customer'
    end
  end

  resources :imports do
    collection do
      post 'create_customer_info'
      get 'csv_template'
      get 'get_upload_status'
    end
  end

  resources :email_activity do
    collection do
      post 'reject_list'
    end
  end

  resources :chat do
    collection do
      get 'identity'
    end
  end

  resources :alert_config do
    collection do
      post 'change_event_status'
      post 'change_channel_status'
      get 'alerts'
      post 'send_alerts'
      post 'update_view_status'
      post 'update_alert_config'
      post 'create_alert_event'
      post 'delete_alert_event'
      post 'get_alert_placeholders'
      post 'update_alert_event'
    end
  end

  resources :dashboard do
    collection do
      post 'get_businesses_info'
      post 'user_engaged_results'
      post 'planner_details'
      get 'post_reviews'
      get 'alerts'
      get 'post_revision'
      post 'get_revision_info'
      get 'get_piwik_info'
    end
  end
end
