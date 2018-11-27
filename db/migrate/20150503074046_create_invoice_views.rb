class CreateInvoiceViews < ActiveRecord::Migration
  def change
    create_table :invoice_views do |t|
      t.references :invoice, index: true
      t.string :ip

      t.timestamps null: false
    end
    add_foreign_key :invoice_views, :invoices
  end
end
