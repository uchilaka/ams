# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  family_name            :string
#  given_name             :string
#  last_request_at        :datetime
#  locked_at              :datetime
#  nickname               :string
#  providers              :string           default([]), is an Array
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  timeout_in             :integer          default(1800)
#  uids                   :jsonb
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
Fabricator(:user) do
  email { Faker::Internet.email }
  given_name { Faker::Name.gender_neutral_first_name }
  family_name { Faker::Name.last_name }
  password { Faker::Internet.password(min_length: 8) }

  # after_build do |attrs|
  #   Fabricate.build(:user_profile, user_id: attrs.id)
  # end
end
