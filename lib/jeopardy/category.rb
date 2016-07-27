require 'pry'

module Jeopardy
  class Category
    attr_reader :clues, :name

    def initialize(name, clue_array)
      @name = name
      @clues = clue_array
    end
  end
end
