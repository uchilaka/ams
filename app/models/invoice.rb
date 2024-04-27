# frozen_string_literal: true

class Invoice
  include DocumentRecord
  include Mongoid::Attributes::Dynamic

  field :vendor_record_id, type: String
  field :vendor_recurring_group_id, type: String
  field :invoice_number, type: String
  field :payment_vendor, type: String
  field :status, type: String
  # { email_address }
  field :invoicer, type: Hash
  field :accounts, type: Array
  field :viewed_by_recipient, type: Boolean
  field :invoiced_at, type: Time
  field :due_at, type: Time
  field :currency_code, type: String
  # { currency_code, value }
  field :amount, type: Hash
  # { currency_code, value }
  field :due_amount, type: Hash
  # { payments: { paid_amount: { currency_code, value } } }
  field :payments, type: Hash
  field :links, type: Array

  validates :payment_vendor,
            presence: true,
            inclusion: { in: %w[paypal] }

  PAYPAL_BASE_URL = ENV.fetch('PAYPAL_BASE_URL', Rails.application.credentials.paypal&.base_url).freeze

  def payment_vendor_url
    "#{PAYPAL_BASE_URL}/invoice/s/details/#{vendor_record_id}"
  end

  def recurring?
    vendor_recurring_group_id.present?
  end
end
