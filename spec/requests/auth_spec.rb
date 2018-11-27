# encoding: utf-8

require "rails_helper"

describe "auth" do

  describe "login" do

    before do
      create(:user, email: 'a@a.com', password: 'password123', password_confirmation: 'password123' )
      visit new_user_session_path
    end

    context "good credentials" do

      it "should regirect them to new invoice url" do
        fill_in "user[email]", with: "a@a.com"
        fill_in "user[password]", with: "password123"
        click_button "Login"

        expect(page.current_path).to eq(new_invoice_path)
      end
    end

    context "bad credentials" do

      it "should keep them on login url" do
        fill_in "user[email]", with: "a@a.com"
        fill_in "user[password]", with: "badpass"
        click_button "Login"

        expect(page.current_path).to eq(new_user_session_path)
      end
    end
  end

  describe "registration" do

    it "should change user count" do
      visit new_user_registration_path

      expect do
        fill_in "user[email]", with: "a@a.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"
        click_button "SIGN UP NOW"
      end.to change { User.count }.by(1)

      expect(page.current_path).to eq(new_invoice_path)
    end
  end
end
