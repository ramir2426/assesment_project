desc "Create recurring invoices"

task :issue_recurring_invoices => :environment do
  RecurringInvoice.where("next_issue_at < ?", Time.now).each do |r|

    invoice = r.create_new_invoice!

    if invoice.payment_gateway && r.payment_gateway && r.payment_customer_id
      payment_manager = PaymentManager.new(invoice.payment_gateway, invoice.currency, invoice.user)
      charge_succesful = payment_manager.charge!(invoice.total, token: r.payment_customer_id)

      if charge_succesful
        InvoicePayment.new(invoice: invoice)
        InvoiceMailer.payment_complete_payer(invoice).deliver_now
        InvoiceMailer.payment_complete_issuer(invoice).deliver_now

      # charge was NOT successful
      else
        invoice.update_attribute(:next_charge_at, 3.days.from_now)
        InvoiceMailer.retry_notice_to_payer(invoice).deliver_now
        InvoiceMailer.retry_notice_to_issuer(invoice).deliver_now
      end
    end

    # schedule next issue date
    if r.interval_in_days.days.from_now < r.to_date
      r.update_attribute(:next_issue_at, r.interval_in_days.days.from_now)
    else
      r.update_attribute(:next_issue_at, nil)
    end
  end
end

task :retry_failed_recurring_invoices => :environment do
  Invoice.where("next_charge_at < ?", Time.now).each do |invoice|

    if invoice.payment_gateway && invoice.recurring_invoice.payment_gateway && invoice.recurring_invoice.payment_customer_id
      payment_manager = PaymentManager.new(invoice.payment_gateway, invoice.currency, invoice.user)
      charge_succesful = payment_manager.charge!(invoice.total, token: invoice.recurring_invoice.payment_customer_id)

      if charge_succesful
        invoice.update_attribute(:next_charge_at, nil)
        InvoicePayment.new(invoice: invoice)
        InvoiceMailer.payment_complete_payer(invoice).deliver_now
        InvoiceMailer.payment_complete_issuer(invoice).deliver_now

      # charge was NOT successful
      else
        invoice.update_attribute(:next_charge_at, 3.days.from_now)
        InvoiceMailer.retry_notice_to_payer(invoice).deliver_now
        InvoiceMailer.retry_notice_to_issuer(invoice).deliver_now
      end
    end
  end
end