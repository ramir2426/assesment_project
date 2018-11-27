class InvoicePaymentsController < ApplicationController

  layout 'public_invoice'

  before_action :init_invoice_and_payment

  def create
    redirect_to :back and return unless Invoice::PAYMENT_GATEWAYS.include?(params[:gateway])

    @charge_succesful = nil
    @recurring_invoice = @invoice.recurring_invoice
    @payment_manager = PaymentManager.new(params[:gateway], @invoice.currency, @invoice.user)

    # if recurring, save card for later
    if @recurring_invoice.present?
      result = @payment_manager.create_customer(params[:client_payment_nonce])

      if result != false && result[:customer].present?
        @recurring_invoice.update_attributes(payment_customer_id: result[:customer].id)
        @charge_succesful = @payment_manager.charge!(@invoice.total, token: result[:customer].id)
      else
        @charge_succesful = false
      end

      if !@charge_succesful

        if result != false && result[:customer].present?
          @payment_manager.delete_customer(@recurring_invoice.payment_customer_id)
          @recurring_invoice.update_attributes(payment_customer_id: nil)
        end
      end

    # if not recurring, charge just once without card saving
    else
      @charge_succesful = @payment_manager.charge!(@invoice.total, nonce: params[:client_payment_nonce])
    end

    if @charge_succesful
      if @payment.save! && @invoice.update_attribute(:paid_date, Date.today)
        InvoiceMailer.payment_complete_payer(@invoice).deliver_now
        InvoiceMailer.payment_complete_issuer(@invoice).deliver_now
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: {}, status: (@charge_succesful ? 201 : 422) }
    end
  end

  def destroy
    if @invoice.recurring_invoice.present?
      @payment_manager = PaymentManager.new(@invoice.payment_gateway, @invoice.currency, @invoice.user)
      @payment_manager.delete_customer(@invoice.recurring_invoice.payment_customer_id)
      @invoice.recurring_invoice.update_attribute(:payment_customer_id, nil)
    end

    redirect_to public_show_invoice_path(secure_id: @invoice.secure_id)
  end

private

  def init_invoice_and_payment
    @invoice = Invoice.where(secure_id: params[:secure_id]).first

    raise ActiveRecord::RecordNotFound if @invoice.nil? || (@invoice.invoice_payment.present? && !@invoice.recurring_invoice)
    raise ActiveRecord::RecordNotFound if @invoice.payment_gateway.nil?

    @payment = InvoicePayment.new(invoice: @invoice)
  end
end
