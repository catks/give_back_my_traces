require 'give_back_my_traces'

# Usage:
#   ruby simple.rb
#   GBMT_MODE=normal GBMT_BACKTRACE_MAX_LINES=2 ruby multiple.rb
#   GBMT_MODE=verbose GBMT_BACKTRACE_MAX_LINES=5 ruby multiple.rb
#   GBMT_MODE=silent ruby simple.rb

GiveBackMyTraces.start

def bar(baz:)
end

def some_method
  bar rescue  StandardError
  bar(baz: 42, invalid_key: 42) rescue  StandardError
end

some_method
