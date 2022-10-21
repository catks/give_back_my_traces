# frozen_string_literal: true

module ErrorHelper
  class << self
    def multiple_errors
      raise StandardError, "Error 1"
    rescue StandardError
      raise StandardError, "Error 2"
    end

    def no_errors; end
  end
end
