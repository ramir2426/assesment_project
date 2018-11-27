# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181116225003) do

  create_table "clients", force: :cascade do |t|
    t.string   "business_name"
    t.string   "contact_name"
    t.string   "email"
    t.text     "business_address"
    t.string   "invoice_prefix"
    t.string   "currency"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "company_size",     default: 0
  end

  add_index "clients", ["user_id"], name: "index_clients_on_user_id"

  create_table "invoice_payments", force: :cascade do |t|
    t.integer  "invoice_id"
    t.float    "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "invoice_payments", ["invoice_id"], name: "index_invoice_payments_on_invoice_id"

  create_table "invoice_views", force: :cascade do |t|
    t.integer  "invoice_id"
    t.string   "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "invoice_views", ["invoice_id"], name: "index_invoice_views_on_invoice_id"

  create_table "invoices", force: :cascade do |t|
    t.text     "from_company"
    t.text     "to_company"
    t.string   "invoice_number"
    t.string   "invoice_prefix"
    t.date     "date_issued"
    t.date     "due_date"
    t.float    "total_due"
    t.float    "subtotal"
    t.float    "total"
    t.string   "tax_name"
    t.float    "tax_amount"
    t.text     "notes"
    t.date     "paid_date"
    t.string   "currency"
    t.integer  "user_id"
    t.integer  "client_id"
    t.text     "invoice_items"
    t.string   "secure_id"
    t.string   "payment_gateway"
    t.datetime "next_charge_at"
    t.integer  "recurring_invoice_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "invoices", ["client_id"], name: "index_invoices_on_client_id"
  add_index "invoices", ["recurring_invoice_id"], name: "index_invoices_on_recurring_invoice_id"
  add_index "invoices", ["secure_id"], name: "index_invoices_on_secure_id"
  add_index "invoices", ["user_id"], name: "index_invoices_on_user_id"

  create_table "recurring_invoices", force: :cascade do |t|
    t.string   "profile_name"
    t.date     "from_date"
    t.date     "to_date"
    t.date     "next_issue_at"
    t.float    "subtotal"
    t.string   "tax_name"
    t.float    "tax_amount"
    t.float    "total"
    t.string   "currency"
    t.integer  "client_id"
    t.integer  "user_id"
    t.integer  "due_in_days"
    t.text     "invoice_items"
    t.text     "notes"
    t.string   "payment_gateway"
    t.string   "payment_customer_id"
    t.integer  "interval_in_days"
    t.boolean  "auto_charge"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "recurring_invoices", ["client_id"], name: "index_recurring_invoices_on_client_id"
  add_index "recurring_invoices", ["user_id"], name: "index_recurring_invoices_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                    default: "",    null: false
    t.string   "encrypted_password",       default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "braintree_merchant_id"
    t.string   "braintree_public_key"
    t.string   "braintree_private_key"
    t.string   "stripe_public_key"
    t.string   "stripe_private_key"
    t.datetime "active_until"
    t.datetime "last_billing_date"
    t.string   "account_plan"
    t.boolean  "free_trial_2_days_email"
    t.boolean  "free_trial_ended_email"
    t.boolean  "hide_braintree_fx_notice", default: false
    t.string   "bt_customer_id"
    t.string   "bt_subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.string   "business_name"
    t.text     "business_address"
    t.string   "logo"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
