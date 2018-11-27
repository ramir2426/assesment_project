class InvoiceView < ActiveRecord::Base
  belongs_to :invoice

  validates :invoice, presence: true
  validates :ip, presence: true
end
