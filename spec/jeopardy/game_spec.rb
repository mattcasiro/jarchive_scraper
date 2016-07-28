require 'jeopardy/game'

module Jeopardy

  describe Game do
    subject { Game.new("source", "rounds") }

    it { is_expected.to respond_to(:source) }
    it { is_expected.to respond_to(:rounds) }

  end
end
