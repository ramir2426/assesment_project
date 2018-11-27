# encoding: utf-8

require "rails_helper"

describe "account settings" do

  before do
    @user = create(:user)
    login_as(@user)
    visit payments_integration_path
  end

  describe 'braintree' do

    context 'valid keys' do

      before { Braintree::ClientToken.stub(:generate) { true } }

      it "should update braintree keys" do
        fill_in "user[braintree_merchant_id]", with: "ValidMerchandId"
        fill_in "user[braintree_public_key]", with: "ValidPublicKey"
        fill_in "user[braintree_private_key]", with: "ValidPrivateKey"

        click_button "Save"

        expect(page).to_not have_content('Invalid Braintree keys')

        expect(@user.reload.braintree_merchant_id).to eq('ValidMerchandId')
        expect(@user.reload.braintree_public_key).to eq('ValidPublicKey')
        expect(@user.reload.braintree_private_key).to eq('ValidPrivateKey')
      end
    end

    context 'invalid keys' do

      before { Braintree::ClientToken.stub(:generate) { raise "a" } }

      it "should not update braintree keys" do
        fill_in "user[braintree_merchant_id]", with: "InValidMerchandId"
        fill_in "user[braintree_public_key]", with: "InValidPublicKey"
        fill_in "user[braintree_private_key]", with: "InValidPrivateKey"

        click_button "Save"

        expect(page).to have_content('Invalid Braintree keys')

        expect(@user.reload.braintree_merchant_id).to_not eq('InValidMerchandId')
        expect(@user.reload.braintree_public_key).to_not eq('InValidPublicKey')
        expect(@user.reload.braintree_private_key).to_not eq('InValidPrivateKey')
      end
    end
  end

  describe 'stripe' do

    context 'valid keys' do

      before { Stripe::Account.stub(:retrieve) { true } }

      it "should update braintree keys" do
        fill_in "user[stripe_public_key]", with: "ValidMerchandId"
        fill_in "user[stripe_private_key]", with: "ValidPublicKey"

        click_button "Save"

        expect(page).to_not have_content('Invalid Stripe keys')

        expect(@user.reload.stripe_public_key).to eq('ValidMerchandId')
        expect(@user.reload.stripe_private_key).to eq('ValidPublicKey')
      end
    end

    context 'invalid keys' do

      before { Stripe::Account.stub(:retrieve) { raise "a" } }

      it "should not update braintree keys" do
        fill_in "user[stripe_public_key]", with: "InValidMerchandId"
        fill_in "user[stripe_private_key]", with: "InValidPublicKey"

        click_button "Save"

        expect(page).to have_content('Invalid Stripe keys')

        expect(@user.reload.stripe_public_key).to_not eq('InValidMerchandId')
        expect(@user.reload.stripe_private_key).to_not eq('InValidPublicKey')
      end
    end
  end
end
