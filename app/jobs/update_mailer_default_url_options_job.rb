# frozen_string_literal: true

class UpdateMailerDefaultURLOptionsJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 5,
                  # Skip sending it to the dead queue
                  dead: false

  def perform(*args)
    # Log the baseline for the default_url_options for ActionMailer
    Rails.logger.info "#{self.class.name} BASELINE: ActionMailer default_url_options", default_url_options:
      Rails.configuration.action_mailer.default_url_options = VirtualOfficeManager.default_url_options
    # Check if the default_url_options have been updated
    Rails.logger.info "#{self.class.name} COMPARE: ActionMailer default_url_options", default_url_options:
  end

  private

  def default_url_options
    Rails.configuration.action_mailer.default_url_options
  end

  def healthz_endpoint
    "https://#{VirtualOfficeManager.hostname}/healthz"
  end
end
