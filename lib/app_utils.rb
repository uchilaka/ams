# frozen_string_literal: true

require 'fileutils'

class AppUtils
  class << self
    def yes?(value)
      return true if [true, 1].include?(value)
      return false if value.nil?

      /^Y(es)?|^T(rue)|^On$/i.match?(value.to_s.strip)
    end

    # LetterOpener should be enabled by default in the development environment
    def letter_opener_enabled?
      !yes?(ENV.fetch('LETTER_OPENER_DISABLED', 'no'))
    end

    def send_emails?
      yes?(ENV.fetch('SEND_EMAILS_ENABLED', Rails.env.production? ? 'yes' : 'no'))
    end

    def ping?(host)
      result = system("ping -c 1 -t 3 -W 1 #{host}", out: '/dev/null', err: '/dev/null')
      result.nil? ? false : result
    end

    def healthy?(resource_url)
      response = Faraday.get(resource_url) do |options|
        options.headers = {
          'User-Agent' => 'VirtualOfficeManager health check bot v1.0'
        }
      end
      response.success?
    end
  end
end
