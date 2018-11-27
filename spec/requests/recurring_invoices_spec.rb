# encoding: utf-8

require "rails_helper"

describe "recurring invoices" do

  before do
    @user = create(:user)
    @client = create(:client, user: @user)
    login_as(@user)
  end

  describe "index" do

    before do
      2.times { create(:recurring_invoice, user: @user) }
      2.times { create(:recurring_invoice) }

      visit recurring_invoices_path
    end

    it "should display 2 clients" do
      within('table.recurring-invoices') do
        expect(page).to have_selector('.item', count: 2)
      end
    end
  end

  describe "create" do

    before { visit new_recurring_invoice_path }

    it "should create new recurring invoice" do
      expect do
        select @client.business_name, from: "recurring_invoice[client_id]"
        fill_in "recurring_invoice[profile_name]", with: "Test profile"
        fill_in "recurring_invoice[to_date]", with: 28.days.from_now
        fill_in "invoice_items_0_qty", with: "1"
        fill_in "invoice_items_0_unit_price", with: "1"
        click_button "Save"
      end.to change { @client.recurring_invoices.reload.count }.by(1)
    end
  end

  # describe "update" do

  #   before do
  #     @recurring_invoice = create(:recurring_invoice, user: @user)
  #     visit edit_recurring_invoice_path(@recurring_invoice)
  #   end

  #   it "should update recurring invoice" do
  #     fill_in "recurring_invoice[notes]", with: "Changed"
  #     click_button "Save"

  #     expect(page).to have_content('Changed')
  #     expect(page.current_path).to eq(recurring_invoice_path(@recurring_invoice))
  #   end
  # end

  describe "destroy" do

    before do
      @recurring_invoice = create(:recurring_invoice, user: @user, client: @client)
      # visit edit_recurring_invoice_path(@recurring_invoice)
    end

    # it "should delete recurring invoice" do
    #   expect do
    #     click_link "Delete Recurring Invoice"
    #   end.to change { @client.recurring_invoices.reload.count }.by(-1)
    # end

    it "should delete recurring invoice" do
      expect do
        delete "/recurring_invoices/#{@recurring_invoice.id}"
      end.to change { @client.recurring_invoices.reload.count }.by(-1)
    end
  end
end
