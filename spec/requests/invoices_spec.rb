# encoding: utf-8

require "rails_helper"

describe "invoices" do

  before do
    @user = create(:user)
    @client = create(:client, user: @user)
    login_as(@user)
  end

  describe "index" do

    before do
      2.times { create(:invoice, user: @user) }
      2.times { create(:invoice) }

      visit invoices_path
    end

    it "should display 2 clients" do
      within('table.invoices') do
        expect(page).to have_selector('.item', count: 2)
      end
    end
  end

  describe "create" do

    before { visit new_invoice_path }

    it "should create new invoice" do
      expect do
        select @client.business_name, from: "invoice[client_id]"
        fill_in "invoice_items_0_qty", with: "1"
        fill_in "invoice_items_0_unit_price", with: "1"
        click_button "Create and Send"
      end.to change { @client.invoices.reload.count }.by(1)
    end
  end

  describe "update" do

    before do
      @invoice = create(:invoice, user: @user)
      visit edit_invoice_path(@invoice)
    end

    it "should update invoice" do
      fill_in "invoice[notes]", with: "Changed"
      fill_in "invoice_items_0_qty", with: "1"
      fill_in "invoice_items_0_unit_price", with: "1"
      click_button "Save"

      expect(page).to have_content('Changed')
      expect(page.current_path).to eq(invoice_path(@invoice))
    end
  end

  describe "destroy" do

    before do
      @invoice = create(:invoice, user: @user, client: @client)
      visit edit_invoice_path(@invoice)
    end

    it "should delete the invoice" do
      expect do
        click_link "Delete Invoice"
      end.to change { @client.invoices.reload.count }.by(-1)
    end
  end
end
