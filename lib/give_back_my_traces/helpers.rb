# frozen_string_literal: true

module GiveBackMyTraces
  # Helper class with error formating methods
  module Helpers
    class << self
      def pretty_print(errors, verbose: false)
        errors.each do |error|
          $stdout.puts pretty_format(error, verbose: verbose)
        end
      end

      def pretty_format(error, verbose: false)
        backtrace_max_lines = verbose ? 1000 : config[:backtrace][:max_lines]

        <<~FORMAT
          ----------------------------------------------------
           Error: #{error.class}
           Message: #{error.message}
           Backtrace:
             #{format_backtrace(error.backtrace, max_lines: backtrace_max_lines)}
          ----------------------------------------------------
        FORMAT
      end

      private

      def format_backtrace(backtrace, max_lines:)
        backtrace_lines = backtrace.first(max_lines).join("\n   ")

        return "#{backtrace_lines}\n   ..." if backtrace.size > max_lines

        backtrace_lines
      end

      def config
        GiveBackMyTraces.config
      end
    end
  end
end
