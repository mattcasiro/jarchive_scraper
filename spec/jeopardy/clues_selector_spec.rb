require 'jeopardy/clues_selector'

module Jeopardy
  describe CluesSelector do
    BASE_PATH = 'spec/jeopardy/fixtures/'

    let(:game_337) { JArchiveScraper.new.new_game!(BASE_PATH + 'show_337_id_4260.html') }
    let(:game_6474) { JArchiveScraper.new.new_game!(BASE_PATH + 'show_6474_id_4010.html') }

    context "A video daily double clue, but no link" do
      let(:round) { CluesSelector.new(game_337.rounds[0]).round }

      it("replaces clue contents with 'nil'") do
        expect(round.categories[1].clues[1].question).to eql(nil)
        expect(round.categories[1].clues[1].answer).to eql(nil)
      end
    end

    context "A clue with a link in the answer" do
      let(:round) { CluesSelector.new(game_6474.rounds[0]).round }

      it("replaces clue contents with 'nil'") do
        expect(round.categories[3].clues[0].question).to eql(nil)
        expect(round.categories[3].clues[0].answer).to eql(nil)
      end
    end
  end
end
