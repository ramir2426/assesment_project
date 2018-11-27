class AddCompanySizeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :company_size, :integer, default: 0
  end
end
