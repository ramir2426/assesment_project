class AccountsController < ApplicationController

  def edit
    @account = current_user
  end

  def payments_integration
    @account = current_user
  end

  def update
    current_user.update_attributes(user_params)
    flash[:braintree_error] = true if current_user.errors[:braintree_merchant_id].any?
    flash[:stripe_error] = true if current_user.errors[:stripe_private_key].any?
    redirect_to :back
  end

  def hide_braintree_fx_notice
    current_user.update_attribute(:hide_braintree_fx_notice, true)
    head 200
  end

private

  def user_params
    if params[:user]
      params[:user] = params[:user].except(:password) if params[:user][:password].try(:empty?)
      params[:user] = params[:user].except(:password_confirmation) if params[:user][:password_confirmation].try(:empty?)
    end

    params.require(:user).permit(:contact_name,
                                 :business_name,
                                 :business_address,
                                 :password,
                                 :password_confirmation,
                                 :logo,
                                 :logo_cache,
                                 :remove_logo,
                                 :braintree_merchant_id,
                                 :braintree_public_key,
                                 :braintree_private_key,
                                 :stripe_public_key,
                                 :stripe_private_key)
  end
end