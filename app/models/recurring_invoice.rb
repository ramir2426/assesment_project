class RecurringInvoice < ActiveRecord::Base

  belongs_to :client
  belongs_to :user
  has_many :invoices

  serialize :invoice_items, Array

  validates :client, presence: true
  validates :due_in_days, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :from_date, presence: true
  validates :to_date, presence: true
  validates :interval_in_days, presence: true
  validates :currency, presence: true, inclusion: { in: Currencies::LIST }
  validates :payment_gateway, inclusion: { in: Invoice::PAYMENT_GATEWAYS }, allow_nil: true
  validates :next_issue_at, presence: true
  validate :check_client_ownership

  before_validation :calculate_total
  before_validation :set_next_issue_at, on: :create
  after_create :track_metrics
  before_destroy :delete_payment_data

  strip_attributes only: [:payment_gateway, :tax_name]

  def auto_charge?
    payment_gateway.present? ? 'Yes' : 'No'
  end

  def card_saved?
    self.payment_gateway.present? && self.payment_customer_id.present?
  end

  def create_new_invoice!
    i = Invoice.new(
      payment_gateway: self.payment_gateway,
      notes: self.notes,
      invoice_items: self.invoice_items,
      currency: self.currency,
      user_id: self.user_id,
      client_id: self.client_id,
      due_date: self.due_in_days.days.from_now,
      date_issued: Time.now,
      invoice_number: Invoice.next_number_for(self.user),
      recurring_invoice: self
    )

    i.tap(&:save!)
  end

private

  def track_metrics
    Metric.track('Recurring invoice created')
  end

  def check_client_ownership
    errors.add(:client, "does not belong to user") if client.user != self.user
  end

  def check_to_date
    errors.add(:to_date, "can't be in the past") if self.to_date < Date.today
    errors.add(:to_date, "can't precede From Date") if self.to_date < self.from_date
  end

  def calculate_total
    self.subtotal = invoice_items.inject(0.0) { |mem, i| mem + i["qty"].to_f * i["unit_price"].to_f }
    self.total = self.subtotal.to_f + self.tax_amount.to_f
  end

  def set_next_issue_at
    self.next_issue_at = self.due_in_days.days.from_now if self.due_in_days
  end

  def delete_payment_data
    if self.payment_customer_id
      PaymentManager.new(self.payment_gateway, self.currency, self.user).delete_customer(self.payment_customer_id)
    end
  end
end
