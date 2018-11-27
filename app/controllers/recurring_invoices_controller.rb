class RecurringInvoicesController < ApplicationController

  before_filter :load_client_list, only: [:new, :edit, :create, :update]
  before_filter :control_plan_access, except: [:restricted]

  def index
    @recurring_invoices = current_user.recurring_invoices.page(params[:page])
    redirect_to action: :new if @recurring_invoices.empty?
  end

  def new
    @recurring = RecurringInvoice.new(user: current_user, currency: 'USD', interval_in_days: 14)
    @recurring.invoice_items = [ { } ]
    @recurring.from_date = Date.today.to_date

    @from_company = current_user.from_company

    @recurring.due_in_days = 7
  end

  def create
    @recurring = RecurringInvoice.new(recurring_invoice_params.merge(user: current_user).except(:invoice_items).merge(invoice_items: params[:invoice_items].to_a.map(&:last)))

    if @recurring.save
      @recurring.create_new_invoice! if @recurring.from_date == Date.today
      redirect_to recurring_invoice_path(@recurring)
    else
      render :new
    end
  end

  def show
    @recurring = current_user.recurring_invoices.where(id: params[:id]).first
    @from_company = current_user.from_company
  end

  # def edit
  #   @recurring = current_user.recurring_invoices.where(id: params[:id]).first
  #   @from_company = current_user.from_company
  # end

  # def update
  #   invoice = current_user.recurring_invoices.where(id: params[:id]).first
  #   invoice.update_attributes(recurring_invoice_params.except(:invoice_items).merge(invoice_items: params[:invoice_items].to_a.map(&:last)))
  #   redirect_to recurring_invoice_path(invoice)
  # end

  def destroy
    current_user.recurring_invoices.where(id: params[:id]).first.destroy
    redirect_to recurring_invoices_path
  end

  def restricted
  end

private

  def recurring_invoice_params
    params.require(:recurring_invoice).permit(
      :due_in_days,
      :notes,
      :invoice_items,
      :currency,
      :client_id,
      :from_date,
      :to_date,
      :interval_in_days,
      :profile_name,
      :payment_gateway,
      :tax_name,
      :tax_amount
    )
  end

  def load_client_list
    @client_list = current_user.clients.map { |c| [c.business_name, c.id, { 'data-to-company' => c.to_company }] }
  end

  def control_plan_access
    redirect_to action: :restricted if current_user.account_plan == 'starter'
  end
end
