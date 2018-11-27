# encoding: utf-8

require "rails_helper"

describe "clients" do

  before do
    @user = create(:user)
    login_as(@user)
  end

  describe "index" do

    before do
      2.times { create(:client, user: @user ) }
      2.times { create(:client) }

      visit clients_path
    end

    # 2 mine + 1 is initial demo sample client
    it "should display 3 clients" do
      within('table.clients') do
        expect(page).to have_selector('.item', count: 3)
      end
    end
  end

  describe "create" do

    before { visit new_client_path }

    it "should create new client" do
      expect do
        fill_in "client[business_name]", with: "Test"
        fill_in "client[contact_name]", with: "Test"
        fill_in "client[email]", with: "a@b.com"
        fill_in "client[business_address]", with: "Test"
        click_button "Save"
      end.to change { @user.clients.reload.count }.by(1)

      expect(page.current_path).to eq(clients_path)
    end
  end

  describe "update" do

    before do
      @client = create(:client, user: @user)
      visit edit_client_path(@client)
    end

    it "should update client" do
      fill_in "client[business_name]", with: "Changed"
      click_button "Save"

      expect(@client.reload.business_name).to eq("Changed")
      expect(page.current_path).to eq(clients_path)
    end
  end

  describe "destroy" do

    before do
      @client = create(:client, user: @user)
      visit edit_client_path(@client)
    end

    it "should delete the client" do
      expect do
        click_link "Delete Client"
      end.to change { @user.clients.reload.count }.by(-1)
    end
  end
end
