# encoding: utf-8

require "rails_helper"

describe "invoice payments" do

  before do
    Stripe::Account.stub(:retrieve) { true }
    @user = create(:user, stripe_public_key: 'a', stripe_private_key: 'b')
    @client = create(:client, user: @user)
    @invoice = create(:invoice, user: @user)
    login_as(@user)
  end

  describe "payment page" do

    context "payment enabled" do

      before { @invoice.update_attribute(:payment_gateway, 'stripe') }

      context "unpaid" do

        before { visit public_show_invoice_path(secure_id: @invoice.secure_id) }

        it "should be on the right page" do
          expect(page).to have_content('Total Due')
        end

        it "should have payment form" do
          expect(page).to have_selector('.payment-form')
        end
      end

      context 'paid by manual mark' do

        before do
          @invoice.update_attribute(:paid_date, Date.today)
          visit public_show_invoice_path(secure_id: @invoice.secure_id)
        end

        it "should not have payment form anymore" do
          expect(page).to_not have_selector('.payment-form')
        end

        it "should display payment indication" do
          expect(page).to have_content('Invoice paid')
        end
      end

      context 'paid by card' do

        before do
          create(:invoice_payment, invoice: @invoice)
          visit public_show_invoice_path(secure_id: @invoice.secure_id)
        end

        it "should not have payment form anymore" do
          expect(page).to_not have_selector('.payment-form')
        end

        it "should display payment indication" do
          expect(page).to have_content('Invoice paid')
        end
      end
    end

    context "payment disabled" do

      before { @invoice.update_attribute(:payment_gateway, nil) }

      context "unpaid" do

        before { visit public_show_invoice_path(secure_id: @invoice.secure_id) }

        it "should not have payment form" do
          expect(page).to_not have_selector('.payment-form')
        end

        it "should not display payment indication" do
          expect(page).to_not have_content('Invoice paid')
        end
      end

      context 'paid by manual mark' do

        before do
          @invoice.update_attribute(:paid_date, Date.today)
          visit public_show_invoice_path(secure_id: @invoice.secure_id)
        end

        it "should not have payment form" do
          expect(page).to_not have_selector('.payment-form')
        end

        it "should display payment indication" do
          expect(page).to have_content('Invoice paid')
        end
      end
    end
  end

  describe "charging" do

    before { @invoice.update_attribute(:payment_gateway, 'stripe') }

    describe "invalid gateway" do

      before { post '/charge_card', { gateway: 'wrong', secure_id: @invoice.secure_id }, 'HTTP_REFERER' => public_show_invoice_path(secure_id: @invoice.secure_id) }

      it "should be http 302" do # redirect_to :back
        expect(response.status).to eq(302)
      end
    end

    describe 'braintree' do

      context "valid charge" do

        before { PaymentManager.any_instance.stub(:charge!) { true } }

        it "should be http 201" do
          expect do
            post '/charge_card.json', { gateway: 'braintree', secure_id: @invoice.secure_id }, 'HTTP_REFERER' => public_show_invoice_path(secure_id: @invoice.secure_id)
          end.to change { @invoice.reload.invoice_payment.present? }

          expect(response.status).to eq(201)
        end
      end

      context "invalid charge" do

        before { PaymentManager.any_instance.stub(:charge!) { false } }

        it "should be http 422" do
          expect do
            post '/charge_card.json', { gateway: 'braintree', secure_id: @invoice.secure_id }, 'HTTP_REFERER' => public_show_invoice_path(secure_id: @invoice.secure_id)
          end.to_not change { @invoice.reload.invoice_payment.present? }

          expect(response.status).to eq(422)
        end
      end
    end
  end
end
