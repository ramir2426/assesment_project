# encoding: utf-8

require "rails_helper"

describe "account settings" do

  before do
    @user = create(:user)
    login_as(@user)
    visit edit_account_path
  end

  it "should update user details" do
    fill_in "user[contact_name]", with: "SomeTest ContactName"
    fill_in "user[business_name]", with: "SomeTestBusiness, Inc"
    fill_in "user[business_address]", with: "SomeTestStreet 123"
    click_button "Save"

    expect(@user.reload.contact_name).to eq("SomeTest ContactName")
    expect(@user.reload.business_name).to eq("SomeTestBusiness, Inc")
    expect(@user.reload.business_address).to eq("SomeTestStreet 123")

    expect(page.current_path).to eq(edit_account_path)
  end
end
