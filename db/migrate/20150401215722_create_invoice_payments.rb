class CreateInvoicePayments < ActiveRecord::Migration
  def change
    create_table :invoice_payments do |t|
      t.references :invoice, index: true
      t.float :amount

      t.timestamps null: false
    end
    add_foreign_key :invoice_payments, :invoices
  end
end
