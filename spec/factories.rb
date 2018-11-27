# encoding: utf-8

FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :name do |n|
    "any#{n}@random"
  end

  factory :user do
    email
    business_name "My Company, Ltd"
    business_address "Sr. John st, London"
    password "aaabbbccc123"
    password_confirmation "aaabbbccc123"
  end

  factory :client do
    user
    business_name "Company, Inc"
    contact_name "John Lock"
    email
    business_address "Some avenue 123, NY"
    currency "USD"
  end

  factory :invoice do
    user
    client { create(:client, user_id: user.id) }
    invoice_items { [{ "qty" => 1, "unit_price" => 1 }] }
    due_date { 7.days.from_now }
    date_issued { Date.today }
    currency "USD"
    payment_gateway nil
  end

  factory :invoice_payment do
    invoice
  end

  factory :recurring_invoice do
    user
    client { create(:client, user_id: user.id) }
    invoice_items { [{ "qty" => 1, "unit_price" => 1 }] }
    due_in_days 7
    from_date { Date.today }
    to_date { 28.days.from_now }
    interval_in_days 7
    currency "USD"
  end
end
