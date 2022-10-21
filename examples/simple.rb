require 'give_back_my_traces'

# Usage:
#   ruby simple.rb
#   GBMT_MODE=normal GBMT_BACKTRACE_MAX_LINES=2 ruby simple.rb
#   GBMT_MODE=verbose GBMT_BACKTRACE_MAX_LINES=5 ruby simple.rb
#   GBMT_MODE=silent ruby simple.rb

GiveBackMyTraces.start

def bar(baz:)
end

def some_method
  bar
rescue  StandardError
  # Nothing to see
end

some_method
