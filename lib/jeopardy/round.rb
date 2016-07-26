require 'pry'

module Jeopardy
  class Round
    attr_reader :categories

    def initialize(category_array)
      @categories = category_array
    end
  end
end
