class Client < ActiveRecord::Base

  CURRENCIES = %w(USD EUR GBP)

  belongs_to :user
  has_many :invoices
  has_many :recurring_invoices

  validates :user, presence: true
  validates :business_name, presence: true
  validates :contact_name, presence: true
  validates :email, presence: true
  validates :business_address, presence: true
  validates :currency, presence: true, inclusion: { in: Currencies::LIST }

  after_create :track_metrics

  def to_company
    res = self.business_name.to_s
    res += "\n" + self.business_address.to_s
    res.strip
  end

private

  def track_metrics
    Metric.track('Client created') unless self.email == 'sampleemail@demo.com'
  end
end
