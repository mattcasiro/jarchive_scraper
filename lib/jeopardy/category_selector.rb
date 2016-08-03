module Jeopardy
  class CategorySelector
    attr_reader :round
    LINK_STR = "a href="
    VDD_STR = "[Video Daily Double]"

    # Creates a cleaned round of jeopardy with only valid categories.
    # A valid category must contain three or more valid clues.
    #
    # @param rnd [Round] a round from a valid game of Jeopardy.
    # @raise [ArgumentError] if the round does not contain at least one category.
    def initialize(new_round)
      @round = clean_round(new_round)
      raise ArgumentError, "Round is not valid" if round.categories.empty?
    end

    # Get a randomly selected category
    #
    # @param num [Int] overrides the random category with a specific selection
    def category(num=(0...round.categories.count).sample)
      round.categories[num]
    end

    private
    # Returns a new round that:
    #   - Only contains valid clues
    #   - Only contains categories valid categories and defined above
    def clean_round round
      valid_categories = round.categories.map do |category|
        valid_clues = category.clues.select { |clue| !invalid_clue? clue }
        category = Category.new(category.name, valid_clues)
      end.select { |category| category.clues.size >= 3 }

      Round.new(valid_categories)
    end

    # Returns true if the clue is NOT valid
    def invalid_clue? clue
      clue.answer.nil? ||                   # nil answer
      clue.question.nil? ||                 # nil question
      clue.answer&.include?(LINK_STR) ||    # link in answer
      clue.question&.include?(LINK_STR) ||  # link in question
      clue.answer&.include?(VDD_STR)        # video daily double (no link)
    end
  end
end
