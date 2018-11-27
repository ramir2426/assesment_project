class PaymentManager

  def initialize(gateway, currency, user)
    raise 'Invalid gateway' unless Invoice::PAYMENT_GATEWAYS.include?(gateway)

    @gateway = gateway
    @currency = currency

    if user == 'app'
      Braintree::Configuration.environment = ENV['BRAINTREE_ENV'].to_sym
      Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
      Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
      Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
    else
      if @gateway == 'braintree'
        Braintree::Configuration.environment = ENV['BRAINTREE_ENV'].to_sym
        Braintree::Configuration.merchant_id = user.braintree_merchant_id
        Braintree::Configuration.public_key = user.braintree_public_key
        Braintree::Configuration.private_key = user.braintree_private_key
      elsif @gateway == 'stripe'
        Stripe.api_key = user.stripe_private_key
      end
    end
  end

  def create_customer(payment_nonce, email = nil)
    if @gateway == 'braintree'
      begin
        bt_customer = Braintree::Customer.create(
          payment_method_nonce: payment_nonce
        ).customer

        { customer: bt_customer, payment_token: bt_customer.credit_cards[0].token }
      rescue => e
        return false
      end
    elsif @gateway == 'stripe'
      begin
        stripe_customer = Stripe::Customer.create(source: payment_nonce)

        { customer: stripe_customer, payment_token: stripe_customer.default_source }
      rescue => e
        return false
      end
    end
  end

  def delete_customer(customer_id)
    if @gateway == 'braintree'
      result = Braintree::Customer.delete(customer_id)
      raise "Could not delete BT customer" if !result.success?
    elsif @gateway == 'stripe'
      result = Stripe::Customer.retrieve(customer_id).delete
      raise "Could not delete Stripe customer" if result["deleted"] != true
    end
  end

  def charge!(amount, params = {})
    unless %i(token nonce).include?(params.keys.first)
      raise 'Incorrect payment manager params'
    end

    if @gateway == 'braintree'
      braintree_params = {
        amount: amount.to_f,
        options: {
          submit_for_settlement: true
        }
      }

      braintree_params.merge!(payment_method_token: params[:token]) if params[:token]
      braintree_params.merge!(payment_method_nonce: params[:nonce]) if params[:nonce]

      Braintree::Transaction.sale(braintree_params).success?
    elsif @gateway == 'stripe'
      # https://support.stripe.com/questions/which-zero-decimal-currencies-does-stripe-support
      currency_total = amount.to_f
      unless %w(BIF CLP DJF GNF JPY KMF KRW MGA PYG RWF VND VUV XAF XOF XPF).map(&:downcase).include?(@currency)
        currency_total = currency_total * 100
      end

      stripe_params = {
        amount: currency_total.to_i,
        currency: @currency
      }

      stripe_params.merge!(source: params[:nonce])   if params[:nonce]
      stripe_params.merge!(customer: params[:token]) if params[:token]

      res = Stripe::Charge.create(stripe_params)
      res.status == 'paid' || res.status == 'succeeded'
    end
  end
end