# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id           :uuid             not null, primary key
#  display_name :string           not null
#  readme       :text
#  slug         :string
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  tax_id       :string
#
class Business < Account
  include MaintainsMetadata

  delegate :email, to: :metadata, allow_nil: true

  has_many :products, foreign_key: :vendor_id

  validates :tax_id, allow_blank: true, uniqueness: { case_sensitive: false }

  def email=(value)
    profile.email = value
  end

  def profile
    @metadata ||= BusinessProfile.find_or_create_by(account_id: id)
  end

  alias metadata profile

  def initialize_profile
    # TODO: Refactor this to Metadata::BusinessProfile
    BusinessProfile.create(account_id: id) if profile.blank?
  end

  alias initialize_metadata initialize_profile
end
