require 'jeopardy/round'

module Jeopardy

  describe Round do
    subject { Round.new("category_array") }

    it { is_expected.to respond_to(:categories) }
  end
end
