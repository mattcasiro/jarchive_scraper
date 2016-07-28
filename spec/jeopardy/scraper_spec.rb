require 'jeopardy/scraper'

module Jeopardy
  
  describe JArchiveScraper do
    BASE_PATH = 'spec/jeopardy/fixtures/'

    let :scraper do
      scraper = JArchiveScraper.new
    end

    # Test basic functionality on oldest game
    context "Episode 0001" do
      subject do
        scraper.new_game!(BASE_PATH + 'show_1_id_173_S1E1.html')
      end

      it "has three rounds" do
        expect(subject.rounds.count).to eql(3)
      end
      
      context "the first two rounds" do
        it "each have six categories" do
          expect(subject.rounds[0].categories.count).to eql(6)
          expect(subject.rounds[1].categories.count).to eql(6)
        end

        context "each category" do
          it "has five clues" do
            subject.rounds.each_with_index do |r, i|
              break if i > 1
              r.categories.each do |cat|
                expect(cat.clues.count).to eql(5)
              end
            end
          end
        end
      end

      context "the final round" do
        let :categories do
          categories
        end

        it "has one category" do
          expect(subject.rounds.last.categories.count).to eql(1)
        end

        context "the category" do
          it "has one clue" do
            expect(subject.rounds.last.categories[0].clues.count).to eql(1)
          end
        end
      end

      context "an assortment of specific categories and clues" do
        it "match the expected output" do
          expect(subject.rounds[0].categories[0].name).to eql("LAKES & RIVERS")
          expect(subject.rounds[0].categories[3].name).to eql("FOREIGN CUISINE")
          expect(subject.rounds[1].categories[2].name).to eql("NATIONAL LANDMARKS")
          expect(subject.rounds[1].categories[5].name).to eql("4-LETTER WORDS")
        end
      end
    end
  end
end
