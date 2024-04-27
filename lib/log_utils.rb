# frozen_string_literal: true

module LogUtils
  class << self
    def streaming_enabled?
      AppUtils.yes? ENV.fetch('SEMANTIC_LOGGER_STREAMING_ENABLED', 'yes')
    end

    def streaming_via_http?
      SemanticLogger.appenders.any? { |a| a.is_a?(SemanticLogger::Appender::Http) }
    end

    def initialize_stream
      source_token = ENV.fetch('BETTERSTACK_SOURCE_TOKEN', Rails.application.credentials.betterstack.source_token)
      # BetterStack via HTTPS Appender
      appender = SemanticLogger::Appender::Http.new(
        url: 'https://in.logs.betterstack.com',
        ssl: { verify: OpenSSL::SSL::VERIFY_NONE },
        header: {
          'Content-Type': 'application/json',
          Authorization: "Bearer #{source_token}"
        }
      )
      SemanticLogger.add_appender(appender:)
    end

    def log_path
      log_path = Rails.root.join('log', Time.now.strftime('%Y-%m-%d')).to_s
      FileUtils.mkdir_p(log_path) unless Dir.exist?(log_path)
      log_path
    end

    def log_file(ext: 'log')
      "#{log_path}/#{Rails.env}.#{ext}"
    end
  end
end
