class Plan

  OPTIONS = [
    { name: 'starter', price: 12 },
    { name: 'team', price: 29 },
    { name: 'agency', price: 99 }
  ]

  def self.find(plan_name)
    OPTIONS.select { |o| o[:name] == plan_name }.first
  end
end