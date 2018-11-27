class Metric

  def self.track(event_name)
    StatsMix.track(event_name, 1) if Rails.env.production?
  end
end