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
        it "has one category" do
          expect(subject.rounds.last.categories.count).to eql(1)
        end

        context "the category" do
          it "has one clue" do
            expect(subject.rounds.last.categories[0].clues.count).to eql(1)
          end
        end
      end

      context "an assortment of categories" do
        it "are correctly named" do
          expect(subject.rounds[0].categories[0].name).to eql("LAKES & RIVERS")
          expect(subject.rounds[0].categories[3].name).to eql("FOREIGN CUISINE")
          expect(subject.rounds[1].categories[2].name).to eql("NATIONAL LANDMARKS")
          expect(subject.rounds[1].categories[5].name).to eql("4-LETTER WORDS")
          expect(subject.rounds[2].categories[0].name).to eql("HOLIDAYS")
        end
      end

      context "an assortment of clues" do
        it "provide the correct output" do
          q_and_a_hash = {}
          2.times do |i|
            6.times do |j|
              q_and_a_hash["R#{i}-CA#{j}-CL#{j%5}"] = [subject.rounds[i].categories[j].clues[j%5].question, subject.rounds[i].categories[j].clues[j%5].answer]
            end
          end
          expected = {
            "R0-CA0-CL0"=>["the Jordan", "River mentioned most often in the Bible"],
            "R0-CA1-CL1"=>["the rickshaw", "In 1869 an American minister created this \"oriental\" transportation"],
            "R0-CA2-CL2"=>["a weasel", "When husbands \"pop\" for an ermine coat, they\\'re actually buying this fur"],
            "R0-CA3-CL3"=>["ChÃ¢teaubriand", "French for a toothsome cut of beef served to a twosome"],
            "R0-CA4-CL4"=>["Colonel Chuck Yeager", "Sam Shepard played this barrier breaker in \"The Right Stuff\""],
            "R0-CA5-CL0"=>[nil, nil],
            "R1-CA0-CL0"=>["the walls", "When \"Joshua Fit The Battle Of Jericho\", these took a tumble"],
            "R1-CA1-CL1"=>["Eve Arden", "She was \"Our Miss Brooks\""],
            "R1-CA2-CL2"=>["Plymouth Rock", "The cornerstone of Massachusetts, it bears the date 1620"],
            "R1-CA3-CL3"=>[nil, nil],
            "R1-CA4-CL4"=>["John Wilkes Booth", "After the deed, he leaped to the stage shouting \"Sic semper tyrannis\""],
            "R1-CA5-CL0"=>["shot", "Pulled the trigger or what\\'s in a jigger"]
          }
          expect(q_and_a_hash).to eql(expected)
        end
      end
    end

    # Test game without round 2
    context "A game without a round 2" do
      subject do
        scraper.new_game!(BASE_PATH + "show_317_id_4256.html")
      end
    end


  end
end
