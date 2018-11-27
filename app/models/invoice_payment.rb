class InvoicePayment < ActiveRecord::Base
  belongs_to :invoice

  validates :invoice, presence: true

  after_create :track_metrics

private

  def track_metrics
    Metric.track('Invoice paid by card')
  end
end
