class AddAttributesToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :contact_name
      t.string :business_name
      t.text :business_address
      t.string :logo
    end
  end
end
