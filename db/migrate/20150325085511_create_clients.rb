class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :business_name
      t.string :contact_name
      t.string :email
      t.text :business_address
      t.string :invoice_prefix
      t.string :currency
      t.references :user

      t.timestamps null: false
    end

    add_index :clients, :user_id
  end
end
