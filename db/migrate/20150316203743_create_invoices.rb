class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.text :from_company
      t.text :to_company
      t.string :invoice_number
      t.string :invoice_prefix
      t.date :date_issued
      t.date :due_date
      t.float :total_due
      t.float :subtotal
      t.float :total
      t.string :tax_name
      t.float :tax_amount
      t.text :notes
      t.date :paid_date
      t.string :currency
      t.references :user
      t.references :client
      t.text :invoice_items
      t.string :secure_id
      t.string :payment_gateway
      t.datetime :next_charge_at
      t.references :recurring_invoice, index: true

      t.timestamps null: false
    end

    add_index :invoices, :user_id
    add_index :invoices, :client_id
    add_index :invoices, :secure_id
  end
end
