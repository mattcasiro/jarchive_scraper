module Jeopardy
  # class InvalidRoundError < StandardError
  # end

  class CluesSelector
    attr_reader :round
    LINK_STR = "a href="
    VDD_STR = "[Video Daily Double]"

    def initialize(round)
      @round = sanitize!(round)
    end

    private
    def sanitize!(round)
      round.categories.each do |category|
        category.clues.each do |clue|
          if invalid_clue? clue
            clue.answer = nil
            clue.question = nil
          end
        end
      end
      round
    end

    def invalid_clue? clue
      (
        clue.answer.include?(LINK_STR) ||
        clue.question.include?(LINK_STR) ||
        clue.answer.include?(VDD_STR)
      )
    end
  end
end
