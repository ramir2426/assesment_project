class CreateRecurringInvoices < ActiveRecord::Migration
  def change
    create_table :recurring_invoices do |t|
      t.string :profile_name
      t.date :from_date
      t.date :to_date
      t.date :next_issue_at
      t.float :subtotal
      t.string :tax_name
      t.float :tax_amount
      t.float :total
      t.string :currency
      t.references :client, index: true
      t.references :user, index: true
      t.integer :due_in_days
      t.text :invoice_items
      t.text :notes
      t.string :payment_gateway
      t.string :payment_customer_id
      t.integer :interval_in_days
      t.boolean :auto_charge

      t.timestamps null: false
    end
    add_foreign_key :recurring_invoices, :clients
  end
end
