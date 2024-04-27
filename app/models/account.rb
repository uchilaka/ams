# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id           :uuid             not null, primary key
#  display_name :string           not null
#  slug         :string
#  status       :integer
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  tax_id       :string
#
# Indexes
#
#  index_accounts_on_slug    (slug) UNIQUE
#  index_accounts_on_tax_id  (tax_id) UNIQUE WHERE (tax_id IS NOT NULL)
#

# Doc on Rails STI: https://guides.rubyonrails.org/association_basics.html#single-table-inheritance-sti
class Account < ApplicationRecord
  rolify

  include AASM

  # There are security implications to consider when using deterministic encryption.
  # See https://guides.rubyonrails.org/active_record_encryption.html#deterministic-and-non-deterministic-encryption
  encrypts :tax_id, deterministic: true

  attribute :type, :string, default: 'Account'
  attribute :slug, :string, default: -> { SecureRandom.alphanumeric(4).downcase }

  validates :display_name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :tax_id, uniqueness: { case_sensitive: false }, allow_blank: true, allow_nil: true

  has_and_belongs_to_many :users, join_table: 'accounts_users'

  before_validation :format_tax_id, if: :tax_id_changed?

  has_rich_text :readme

  def primary_users_confirmed?
    # TODO: Check that all primary users have confirmed their email addresses
    true
  end

  enum :status, {
    demo: 1,
    guest: 5,
    active: 10,
    paid: 20,
    payment_due: 25,
    overdue: 30,
    suspended: 35,
    deactivated: 40
  }, scopes: true

  aasm column: :status, enum: true, logger: Rails.logger do
    state :demo
    state :guest, initial: true
    state :active
    state :paid
    state :payment_due
    state :overdue
    state :suspended
    state :deactivated

    event :invite do
      transitions from: %i[demo], to: :guest
    end

    # TODO: Figure out how to designate primary users
    # TODO: Ensure that all primary users are guided to confirm their email addresses
    #   as soon as their accounts are created so service can be activated
    event :activate do
      transitions from: %i[demo guest], to: :active, guard: :primary_users_confirmed?
    end

    event :enroll do
      transitions from: %i[active payment_due overdue], to: :paid
    end

    event :invoice do
      transitions from: %i[active paid], to: :payment_due
    end

    # NOTE: Account suspension happens after the user has failed to pay an invoice or subscription
    #   and the overdue period has passed
    event :suspend do
      transitions from: %i[active payment_due overdue], to: :suspended
    end

    # NOTE: Reactivation can happen after the user has paid an overdue invoice or subscription
    event :reactivate do
      transitions from: %i[suspended overdue deactivated], to: :active
    end

    event :deactivate do
      transitions from: %i[active payment_due overdue suspended], to: :deactivated
    end
  end

  def email
    nil
  end

  private

  def format_tax_id
    self.tax_id = tax_id.upcase if tax_id.present?
  end
end
