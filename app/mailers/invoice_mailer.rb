# encoding: UTF-8

class InvoiceMailer < ActionMailer::Base

  default from: "\"resiboapp.com\" <no-reply@resiboapp.com>"
  layout "mailer"

  def new_invoice_generated(invoice)
    @invoice = invoice
    @user = invoice.user
    mail to: @invoice.client.email, subject: "Invoice ##{@invoice.invoice_number} from #{@user.business_name}"
  end

  def payment_complete_payer(invoice)
    @invoice = invoice
    mail to: @invoice.client.email, subject: "Invoice ##{@invoice.invoice_number} has been paid"
  end

  def payment_complete_issuer(invoice)
    @invoice = invoice
    @user = invoice.user
    mail to: @user.email, subject: "Payment received for invoice ##{@invoice.invoice_number} from #{@invoice.client.business_name}"
  end

  def retry_notice_to_payer(invoice)
    @invoice = invoice
    @client = invoice.client
    mail to: @client.email, subject: "Card Declined"
  end

  def retry_notice_to_issuer(invoice)
    @invoice = invoice
    @user = invoice.user
    mail to: @user.email, subject: "Card Declined"
  end
end
