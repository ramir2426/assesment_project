class InvoicesController < ApplicationController

  before_filter :load_client_list, only: [:new, :edit, :create, :update]
  skip_before_filter :authenticate_user!, only: [:public_show]

  def index
    @invoices = current_user.invoices.page(params[:page])
    redirect_to action: :new if @invoices.empty?
  end

  def new
    @invoice = Invoice.new(user: current_user, currency: 'USD')
    @invoice.invoice_items = [ { } ]
    @invoice.set_from_company
    @invoice.invoice_number = Invoice.next_number_for(@invoice.user)

    @invoice.date_issued = Date.today.to_date
    @invoice.due_date = 14.days.from_now.to_date
  end

  def invoice_items
    render json: current_user.invoices.all.map { |i| i.invoice_items.map { |it| it["description"] } }.flatten.reject(&:empty?).sort
  end

  def create
    redirect_to :new_invoice and return if Invoice.remaining_for_user(current_user) <= 0

    @invoice = Invoice.new(invoice_params.merge(user: current_user).except(:invoice_items).merge(invoice_items: params[:invoice_items].to_a.map(&:last)))

    if @invoice.save
      InvoiceMailer.new_invoice_generated(@invoice).deliver_now
      redirect_to invoice_path(@invoice)
    else
      render :new
    end
  end

  def show
    @invoice = current_user.invoices.where(id: params[:id]).first
  end

  def public_show
    @invoice = Invoice.where(secure_id: params[:secure_id]).first
    raise ActiveRecord::RecordNotFound if @invoice.nil?

    InvoiceView.create!(invoice: @invoice, ip: request.remote_ip) if current_user.nil?

    if @invoice.payment_gateway == 'braintree' && @invoice.user.payment_gateway_set?('braintree')
      PaymentManager.new('braintree', 'usd', @invoice.user) # initializes Braintree globally
      @braintee_client_token = Braintree::ClientToken.generate
    end

    @recurring = @invoice.recurring_invoice

    render layout: 'public_invoice'
  end

  def edit
    @invoice = current_user.invoices.where(id: params[:id]).first
    @invoice.invoice_items = [ { } ] if @invoice.invoice_items.empty?
    redirect_to invoice_path and return if @invoice.paid?
  end

  def update
    invoice = current_user.invoices.where(id: params[:id]).first
    redirect_to invoice_path(invoice) and return if invoice.paid?
    invoice.update_attributes(invoice_params.except(:invoice_items).merge(invoice_items: params[:invoice_items].to_a.map(&:last)))
    redirect_to invoice_path(invoice)
  end

  def mark_unpaid
    invoice = current_user.invoices.where(id: params[:id]).first
    redirect_to invoice_path(invoice) and return if invoice.paid_by_card?
    invoice.update_attribute(:paid_date, nil)
    redirect_to invoice_path(invoice)
  end

  def destroy
    current_user.invoices.where(id: params[:id]).first.destroy
    redirect_to invoices_path
  end

private

  def invoice_params
    params.require(:invoice).permit(
      :invoice_number,
      :invoice_prefix,
      :date_issued,
      :due_date,
      :total_due,
      :subtotal,
      :total,
      :notes,
      :invoice_items,
      :currency,
      :client_id,
      :payment_gateway,
      :paid_date,
      :tax_name,
      :tax_amount
    )
  end

  def load_client_list
    @client_list = current_user.clients.map { |c| [c.business_name, c.id, { 'data-to-company' => c.to_company }] }
  end
end
