# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id           :uuid             not null, primary key
#  display_name :string           not null
#  readme       :text
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  tax_id       :string

# Doc on Rails STI: https://guides.rubyonrails.org/association_basics.html#single-table-inheritance-sti
class Account < ApplicationRecord
  # There are security implications to consider when using deterministic encryption.
  # See https://guides.rubyonrails.org/active_record_encryption.html#deterministic-and-non-deterministic-encryption
  encrypts :tax_id, deterministic: true

  attribute :type, :string, default: 'Account'

  validates :display_name, presence: true

  has_and_belongs_to_many :users, join_table: 'accounts_users'
end
