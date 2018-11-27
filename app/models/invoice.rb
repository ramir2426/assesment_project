class Invoice < ActiveRecord::Base

  PAYMENT_GATEWAYS = %w(braintree stripe)

  belongs_to :user
  belongs_to :client
  belongs_to :recurring_invoice
  has_one :invoice_payment
  has_many :invoice_views
  serialize :invoice_items, Array

  validates :user, presence: true
  validates :client, presence: true
  validates :from_company, presence: true
  validates :to_company, presence: true
  validates :invoice_number, presence: true
  validates :due_date, presence: true
  validates :date_issued, presence: true
  validates :total_due, presence: true
  validates :subtotal, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :currency, presence: true, inclusion: { in: Currencies::LIST }
  validates :payment_gateway, inclusion: { in: PAYMENT_GATEWAYS }, allow_nil: true
  validates :secure_id, presence: true
  validate :check_client_ownership

  before_validation :set_secure_id, on: :create
  before_validation :calculate_totals
  before_validation :set_to_company
  before_validation :set_from_company
  before_validation :set_invoice_number
  after_create :track_metrics
  after_save :track_payment_gateway

  strip_attributes only: [:payment_gateway, :tax_name]

  def status
    if self.paid_date.present?
      'PAID'
    else
      if self.due_date >= Date.today
        'PENDING'
      else
        'OVERDUE'
      end
    end
  end

  def self.remaining_for_user(user)
    if user.account_plan == 'agency' || user.account_plan == 'trial'
      1 # infinite
    elsif user.account_plan == 'team'
      40 - user.invoices.where("created_at >= ?", user.last_billing_date).count
    elsif user.account_plan == 'starter'
      4 - user.invoices.where("created_at >= ?", user.last_billing_date).count
    end
  end

  def owning
    where("due_date >= ? and paid_date is null", Date.today).sum(:amount)
  end

  def paid
    where("paid_date is not null").sum(:amount)
  end

  def paid?
    self.paid_date.present? || self.invoice_payment.present?
  end

  def last_view_date
    self.invoice_views.order("created_at DESC").last.try(:created_at).try(:strftime, "%d. %b %Y %H:%m:%S")
  end

  def paid_by_card?
    self.invoice_payment.present?
  end

  def paid_by_mark?
    self.paid_date.present? && self.invoice_payment.nil?
  end

  def overdue
    where("due_date < ? and paid_date is null", Date.today).sum(:amount)
  end

  def set_from_company
    self.from_company = self.user.from_company
  end

  def self.next_number_for(user)
    user.invoices.order(:invoice_number).last.try(:invoice_number).to_i + 1
  end

private

  def track_metrics
    if self.client.business_name == 'Sample Client' || self.user.business_name == 'Your Company Name, Inc.'
      Metric.track('Demo invoice created')
    else
      Metric.track('Real invoice created')
    end
  end

  def track_payment_gateway
    Metric.track('Invoice with payments created') if self.payment_gateway.present?
  end

  def calculate_totals
    self.subtotal = invoice_items.inject(0.0) { |mem, i| mem + i["qty"].to_f * i["unit_price"].to_f }
    self.total = self.subtotal.to_f + self.tax_amount.to_f
    self.total_due = self.total
  end

  def set_secure_id
    self.secure_id = SecureRandom.hex(32)
    self.secure_id = SecureRandom.hex(32) until !self.class.find_by_secure_id(self.secure_id)
  end

  def set_to_company
    self.to_company = self.client.to_company
  end

  def set_invoice_number
    self.invoice_number = Invoice::next_number_for(self.user) if self.invoice_number.nil?
  end

  def check_client_ownership
    errors.add(:client, "does not belong to user") if client.user != self.user
  end
end
