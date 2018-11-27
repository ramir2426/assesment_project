# encoding: utf-8

require "rails_helper"

describe "invoice payments" do

  before do
    Braintree::ClientToken.stub(:generate) { 'a' }
    @user = create(:user)
    login_as(@user)
  end

  describe 'plan selection' do

    it "should display paymeng form when real plan is selected" do
      visit '/subscription_plans'
      click_link 'CHOSE PLAN'
      expect(page).to have_content('Payment Details')
    end

    it "should display 404 when invalid plan is selected" do
      expect do
        get '/subscription_plans/new?plan_name=nonexistent'
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'plan payment' do

    context 'card accepted' do

      before do

        PaymentManager.any_instance.stub(:create_customer) do
          { customer: Struct.new(:id, :address) do
            def credit_cards
              [Struct.new(:token).new]
            end
          end.new, payment_token: 'a' }
        end

        Braintree::Subscription.stub(:create) do
          Struct.new(:id) do
            def subscription
              Struct.new(:id) do
                def billing_period_end_date
                  7.days.from_now
                end
              end.new
            end
          end.new
        end
        post '/subscription_plans.json', { plan_name: 'starter', client_payment_nonce: 'a' }
      end

      it "should be http 201" do
        expect(response.status).to eq(201)
      end

      it "should activate the user" do
        expect(@user.reload.account_plan).to eq('starter')
      end
    end

    context 'card rejected' do

      before do
        PaymentManager.any_instance.stub(:create_customer) { false }
        Braintree::Subscription.stub(:create) { raise 'a' }
        post '/subscription_plans.json', { plan_name: 'starter', client_payment_nonce: 'a' }
      end

      it "should be http 422" do
        expect(response.status).to eq(422)
      end

      it "should not activate user" do
        expect(@user.reload.account_plan).to eq('trial')
      end
    end

    context 'invalid plan name' do

      it "should be not found 404" do
        expect do
          post '/subscription_plans.json', { plan_name: 'nonexistent', client_payment_nonce: 'a' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
