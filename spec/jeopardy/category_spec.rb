require 'jeopardy/category'

module Jeopardy

  describe Category do

    subject { Category.new("name", "clue array") }

    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:clues) }
  end
end
