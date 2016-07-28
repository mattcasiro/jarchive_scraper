require 'pry'

module Jeopardy
  class Game
    attr_reader :source, :rounds

    def initialize(source, rounds)
      @source = source
      @rounds = rounds
    end
  end
end
