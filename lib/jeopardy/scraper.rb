require 'nokogiri'
require 'open-uri'
require 'time'
require 'pry'
require 'round'
require 'category'
require 'clue'

module Jeopardy
  class JArchiveScraper
    attr_reader :game

    def initialize
      @games = []
    end

    # Create a new game of jeopardy from a given JArchive source
    # If no source is provided, a random game from a random season is selected
    # Pre: web sources must be fully qualified
    def new_game!(source=nil)
      source = game_list(season_list.sample).sample unless source
      @doc = parse source
      games.push Game.new(source, rounds)
      @game = games.last
    end

    private
    attr_reader :doc, :games
    SeasonsURL = "http://www.j-archive.com/listseasons.php"
    TestSeasons = 'test/jeopardy/files/seasons.html'
    TestGames = 'test/jeopardy/files/episodes.html'

    # Uncaught error: Errno::ENOENT if path is invalid
    def parse source
      Nokogiri::HTML(open(source))
    end

    # Get a list of all seasons of Jeopardy from JArchive or a provided source
    def season_list(source=SeasonsURL)
      seasons = parse source
      # 'Real' seasons have names that end in a number (exclude pilot and super jeapordy seasons)
      real_seasons = seasons.xpath("//div[@id='content']//a").select { |season| ('0'..'9').include? season.text[-1] }
      real_seasons.map { |season| season["href"] }.reverse 
    end

    # Get a list of all games of Jeopardy from a season, from JArchive or a provided source
    def game_list(source=TestGames)
      episodes = parse source
      episodes.xpath("//div[@id='content']//table//a").map { |episode| episode["href"] }.reverse
    end
    
    # Get an array of rounds from the parsed document
    def rounds
      # Rounds are split in to nodes as round 1, round 2, and final round
      r_1_node, r_2_node = doc.xpath("//table[@class='round']")
      final_node = doc.xpath("//table[@class='final_round']").first
      
      rounds = []
      rounds[0] = Round.new(categories(r_1_node))
      rounds[1] = Round.new(categories(r_2_node))
      rounds[2] = Round.new(final_categories(final_node))
      rounds
    end

    # Get an array of all categories from the provided source node
    def categories(node)
      category_names = node.xpath(".//td[@class='category_name']").map { |cat| cat.text }
      clue_nodes = node.xpath(".//td[@class='clue']")

      6.times.map do |i|
        Category.new(category_names[i], clues(clue_nodes, i))
      end
    end

    # Get an array containing the final round from the provided source
    def final_categories(node)
      question = clean_question(node.xpath(".//div//@onmouseover")&.first&.value)
      answer = clean_answer (node.xpath(".//div//@onmouseout")&.first&.value)
      [Category.new("Final Jeopardy", Clue.new(question, answer, 0))]
    end

    # Get an array of all clues for a given category (represented numerically) from a given source
    def clues(clue_nodes, i)
      (i..29).step(6).map do |j|
        question = clean_question(clue_nodes[j].xpath(".//div//@onmouseover")&.first&.value)
        answer = clean_answer(clue_nodes[j].xpath(".//div//@onmouseout")&.first&.value)
        Clue.new(question, answer)
      end
    end

    # Get the clean string representation of an answer from a given string source
    def clean_answer(dirty)
      begin
        first = dirty.index(/(?<=stuck', ')./)
        last = dirty.index("')", first)
        dirty[first...last]
      rescue
        # If any step fails, return nil
        nil
      end
    end

    # Get the clean string representation of a question from a given string source
    def clean_question(dirty)
      begin
        first = (dirty.index(/(?<=correct_response\">)./) || dirty.index(/(?<=correct_response\\">)./))
        last = dirty.index("</em>", first)
        dirty[first...last]
      rescue
        # If any step fails, return nil
        nil
      end
    end
  end
end
