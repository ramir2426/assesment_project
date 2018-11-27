Rails.application.routes.draw do

  root 'home#index'
  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :invoices
  resources :recurring_invoices, except: [:edit, :update] do
    get 'restricted', on: :collection
  end
  get '/invoices/public/:secure_id' => 'invoices#public_show', as: :public_show_invoice
  get '/invoices/public/:secure_id/payment' => 'invoice_payments#new', as: :new_invoice_payment
  get '/invoice_items' => 'invoices#invoice_items', as: :invoice_items
  get '/payments_integration' => 'accounts#payments_integration'
  post '/charge_card' => 'invoice_payments#create'
  delete '/cancel_recurring' => 'invoice_payments#destroy'
  resources :clients, except: [:show]
  resources :subscription_plans, except: [:show]
  get 'subscription_plans/cancel' => 'subscription_plans#cancel'
  get 'developer_access' => 'system#developer_access'
  resource :account
  get '/hide_braintree_fx_notice' => 'accounts#hide_braintree_fx_notice'
  get '/mark_unpaid' => 'invoices#mark_unpaid'

  get '/terms' => 'static#show', defaults: { page: 'terms' }
  get '/privacy' => 'static#show', defaults: { page: 'privacy' }
end
