# frozen_string_literal: true

module GiveBackMyTraces
  # class responsible to handle errors that are occurring at Runtime
  class Tracker
    NO_OP = ->(_) {}

    def initialize(filters: [], **options)
      @filters = filters
      @options = options
    end

    def call(error)
      return unless valid?(error)

      print_error(error)
    end

    private

    attr_accessor :filters, :options

    def valid?(error)
      filters.all? { |filter| filter.call(error) }
    end

    def print_error(error)
      warn GiveBackMyTraces::Helpers.pretty_format(error, **options)
    end
  end
end
