class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :logo, LogoUploader

  has_many :invoices
  has_many :recurring_invoices, dependent: :destroy
  has_many :clients, dependent: :destroy

  validate :check_gateway_keys
  validates :account_plan, inclusion: { in: %w(trial starter team agency) }

  before_validation :set_sample_company_data, on: :create
  before_validation :activate_trial, on: :create
  after_create :create_sample_client
  after_create :track_metrics

  def profile_complete?
    contact_name.present? && business_name.present? && business_address.present?
  end

  def from_company
    result = self.business_name.to_s
    result += "\n" + self.business_address.to_s
    result
  end

  def active_days_left
    days = (self.active_until.to_date - Date.today).to_i
    return days < 0 ? 0 : days
  end

  def payment_gateway_set?(gateway_name)
    if gateway_name == 'braintree'
      braintree_merchant_id.present? && braintree_public_key.present? && braintree_private_key.present?
    elsif gateway_name == 'stripe'
      stripe_public_key.present? && stripe_private_key.present?
    else
      false
    end
  end

private

  def create_sample_client
    Client.create!(user: self, email: "sampleemail@demo.com",
                               business_name: "Sample Client",
                               contact_name: "Contact Name",
                               business_address: "Sample Address 123\n San Francisco\nUS",
                               currency: 'USD')
  end

  def track_metrics
    Metric.track('User registration')
  end

  def activate_trial
    self.account_plan = 'trial'
    self.active_until = 14.days.from_now
    self.last_billing_date = Time.now
  end

  def set_sample_company_data
    self.contact_name = "Your Name" unless self.contact_name.present?
    self.business_name = "Your Company Name, Inc." unless self.business_name.present?
    self.business_address = "Business Address\nCity\nCountry"
  end

  def check_gateway_keys
    if self.payment_gateway_set?('braintree')
      begin
        PaymentManager.new('braintree', 'usd', self) # initializes gateway keys globally
        Braintree::ClientToken.generate
        Metric.track('Braintree connected')
      rescue => e
        Metric.track('Braintree connection attempt')
        errors.add(:braintree_merchant_id, "invalid Braintree keys")
      end
    end

    if self.payment_gateway_set?('stripe')
      begin
        Stripe.api_key = self.stripe_private_key
        Stripe::Account.retrieve
        Metric.track('Stripe connected')
      rescue => e
        Metric.track('Stripe connection attempt')
        errors.add(:stripe_private_key, "invalid Stripe keys")
      end
    end
  end
end
