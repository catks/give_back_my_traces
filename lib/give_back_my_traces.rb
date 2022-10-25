# frozen_string_literal: true

require_relative "give_back_my_traces/version"
require_relative "give_back_my_traces/errors_collection"
require_relative "give_back_my_traces/tracker"
require_relative "gbmt"

# Main module to handle GBMT api
#
# Usage:
#
# # With ENV variables to enable (aka: GBMT_ENABLE=1)
#  GiveBackMyTraces.init(mode: :verbose)
#  #  # ...Some code...
#  GiveBackMyTraces.errors # See all the errors rescued so far
#
# # Explicity enabling it
#  GiveBackMyTraces.start(mode: :silent)
#  #  # ...Some code...
#  GiveBackMyTraces.errors # See all the errors rescued so far
#
#
# GiveBackMyTraces.errors.pretty_print # Print errors
module GiveBackMyTraces
  class Error < StandardError; end
  DEFAULT_CONFIG = {
    mode: ENV.fetch("GBMT_MODE", :normal).to_sym,
    backtrace: {
      max_lines: ENV.fetch("GBMT_BACKTRACE_MAX_LINES", 5).to_i
    },
    from: ENV["GBMT_BACKTRACE_FROM"] && Regexp.new(ENV["GBMT_BACKTRACE_FROM"])
  }.freeze

  FROM_BACKTRACE_FILTER = lambda do |error|
    return true if GiveBackMyTraces.config[:from].nil?
    return false unless error.backtrace

    error.backtrace.first.match?(GiveBackMyTraces.config[:from])
  end

  TRACKERS = {
    normal: Tracker.new(filters: [FROM_BACKTRACE_FILTER]),
    silent: Tracker::NO_OP,
    verbose: Tracker.new(filters: [FROM_BACKTRACE_FILTER], verbose: true)
  }.freeze

  class << self
    def init(**options)
      start(**options) if ENV.key?("GBMT_ENABLE")
    end

    def start(**options)
      config.merge!(options)

      @trace = TracePoint.new(:raise) do |tp|
        error = tp.raised_exception

        errors << error

        GiveBackMyTraces::TRACKERS[config[:mode]].call(error)
      end

      @trace.enable

      return unless block_given?

      yield

      stop
    end

    def stop
      @trace&.disable
    end

    def clear
      self.errors = GiveBackMyTraces::ErrorsCollection.new
    end

    def errors
      @errors ||= GiveBackMyTraces::ErrorsCollection.new
    end

    def config
      @config ||= DEFAULT_CONFIG.dup
    end

    private

    attr_writer :errors
  end
end
