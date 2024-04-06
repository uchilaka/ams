# frozen_string_literal: true

module Errors
  class AccountConfirmationRequired < StandardError; end
  class ElevatedPrivilegesRequired < StandardError; end
  class Forbidden < StandardError; end
  class ResourceNotFound < StandardError; end
  class Unauthorized < StandardError; end
  class UnprocessableEntity < StandardError; end
  class InternalServerError < StandardError; end
  class Unsupported < StandardError; end

  class IntegrationRequestFailed < StandardError
    attr_reader :status, :vendor

    def initialize(message, status:, vendor:)
      super(message)
      @status = status
      @vendor = vendor
    end
  end
end
