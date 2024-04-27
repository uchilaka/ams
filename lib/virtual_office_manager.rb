# frozen_string_literal: true

# This class is intended to facilitate access to business related
#   defaults and information with support for retrieving
#   data from secure or encrypted sources.
class VirtualOfficeManager
  class << self
    def hostname
      # TODO: Check if tunnel is available and use the NGROK hostname if so
      #   otherwise, fallback to the configured hostname 👇🏾
      ENV.fetch('HOSTNAME', Rails.application.credentials.hostname)
    end

    def hostname_is_nginx_proxy?
      /\.ngrok\.(dev|app)/.match?(hostname)
    end

    def default_url_options
      # Only run this in the context of a job
      if !defined?(Rails::Server) && Flipper.enabled?(:feat__hostname_health_check)
        healthz_endpoint = "https://#{hostname}/healthz"
        return { host: hostname } if AppUtils.healthy?(healthz_endpoint)
      end

      { host: hostname, port: hostname_is_nginx_proxy? ? nil : ENV.fetch('PORT') }.compact
    end

    def default_entity
      entities&.larcity
    end

    def entities
      Rails.application.credentials.entities
    end

    def entity_by_key(entity_key)
      return nil if entity_key.blank?

      entities&.send(entity_key)
    end

    def logstream_vendor_url
      return nil if logstream_vendor&.team_id.blank? || logstream_vendor&.source_id.blank?

      [
        'https://logs.betterstack.com/team/',
        logstream_vendor.team_id,
        '/tail?s=',
        logstream_vendor.source_id
      ].join
    end

    def logstream_vendor
      Rails.application.credentials.betterstack
    end
  end
end
