class SubscriptionPlansController < ApplicationController

  def index
  end

  def cancel
  end

  def new
    raise ActiveRecord::RecordNotFound if Plan.find(params[:plan_name]).nil?
    @plan = params[:plan_name]
    PaymentManager.new('braintree', 'usd', 'app') # initializes app's own Braintree keys
    @braintee_client_token = Braintree::ClientToken.generate
  end

  def create
    plan = Plan.find(params[:plan_name])
    raise ActiveRecord::RecordNotFound and return if plan.nil?

    bt_subscription = nil
    @payment_manager = PaymentManager.new('braintree', 'usd', 'app')

    begin
      result = @payment_manager.create_customer(params[:client_payment_nonce], email: current_user.email)

      if result[:customer].present?

        current_user.update_attribute(:bt_customer_id, result[:customer].id)
        payment_method_token = result[:customer].credit_cards[0].token

        bt_subscription = Braintree::Subscription.create(
          payment_method_token: payment_method_token,
          plan_id: params[:plan_name]
        ).subscription
      else
        render json: {}, status: 422 and return
      end
    rescue => e
      render json: {}, status: 422 and return
    end

    valid_until = bt_subscription.billing_period_end_date.to_date + 1

    if current_user.update_attributes!(active_until: valid_until,
                                       account_plan: params[:plan_name],
                                       last_billing_date: Time.now,
                                       bt_subscription_id: bt_subscription.id)

      render json: {}, status: 201 and return
    else
      render json: {}, status: 422 and return
    end
  end

  def update
    raise 'Update subscription disabled'
    plan = Plan.find(params[:plan_name])
    raise ActiveRecord::RecordNotFound and return if plan.nil?

    bt_subscription = nil

    begin
      bt_customer = nil

      # update client card
      # if params[:client_payment_nonce]
      #   bt_customer = Braintree::Customer.update(
      #     current_user.bt_customer_id,
      #     payment_method_nonce: params[:client_payment_nonce]
      #   )
      # else
        bt_customer = Braintree::Customer.find(current_user.bt_customer_id)
      # end

      payment_method_token = bt_customer.credit_cards[0].token

      bt_subscription = Braintree::Subscription.update(
        current_user.bt_subscription_id,
        payment_method_token: payment_method_token,
        plan_id: params[:plan_name],
      ).subscription
    rescue => e
      render json: {}, status: 422 and return
    end

    if current_user.update_attributes!(account_plan: params[:plan_name],
                                       last_billing_date: Time.now,
                                       bt_subscription_id: bt_subscription.id)

      render json: {}, status: 201 and return
    else
      render json: {}, status: 422 and return
    end
  end

  def destroy
    if current_user.bt_subscription_id
      result = Braintree::Subscription.cancel(current_user.bt_subscription_id)
      raise "Could not delete BT subscription" if !result.success?
    end

    if current_user.bt_customer_id
      result = Braintree::Customer.delete(current_user.bt_customer_id)
      raise "Could not delete BT customer" if !result.success?
    end

    current_user.destroy
    redirect_to root_url
  end

private

  def client_params
    params.require(:client).permit(
      :business_name,
      :contact_name,
      :email,
      :business_address,
      :currency
    )
  end
end
