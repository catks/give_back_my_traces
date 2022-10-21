# frozen_string_literal: true

require "forwardable"
require "give_back_my_traces/helpers"

module GiveBackMyTraces
  # class to handle errors collected by GBMT
  class ErrorsCollection
    include Enumerable
    include Comparable
    extend Forwardable

    delegate %i[each last <<] => :@errors

    def initialize(errors = [])
      @errors = errors
    end

    def pretty_print
      GiveBackMyTraces::Helpers.pretty_print(@errors)
    end

    def <=>(other)
      @errors <=> other
    end
  end
end
