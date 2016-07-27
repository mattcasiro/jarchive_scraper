require 'jeopardy/clue'

module Jeopardy

  describe Clue do
    subject { Clue.new("question", "answer", 100) }

    it { is_expected.to respond_to(:question) }
    it { is_expected.to respond_to(:answer) }
    it { is_expected.to respond_to(:value) }
  end
end
