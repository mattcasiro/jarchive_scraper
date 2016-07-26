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
      @random = Random.new(Time.now.to_i)
    end

    # Create a new game of jeopardy from a given JArchive source
    # If no source is provided, a random game from a random season is returned
    def new_game!(source=random_game_uri)
      @doc = parse(source)
      games.push Game.new(source, rounds)
      @game = games.last
    end

    private
    attr_reader :source, :doc, :games, :random
    SeasonsURL = "http://www.j-archive.com/listseasons.php"

    def parse(source)
      if source.include?("www.j-archive.com/")
        Nokogiri::HTML(open(source))
      else
        File.open(source) { |f| Nokogiri::HTML(f) }
      end
    end
    
    def random_game_uri
      seasons = season_list(SeasonsURL)
      season = random.rand(seasons.length)
      games = game_list(season_list[season])
      game = random.rand(games.length)
      # TODO Remove debug statements x2
      puts "DEBUG: a random game is: S#{season+1} E#{game+1}"
      puts "DEBUG: source URL: #{games[game]}"
      games[game]
    end
    
    def season_list(url='test/jeopardy/files/seasons.html')
      seasons = parse url
      # 'Real' seasons have names that end in a number (exclude pilot and super jeapordy seasons)
      real_seasons = seasons.xpath("//div[@id='content']//a").select { |season| Float(season.text[-1]) rescue false }
      real_seasons.map { |season| season["href"] }.reverse 
    end

    def game_list(url='test/jeopardy/files/episodes.html')
      episodes = parse url
      episodes.xpath("//div[@id='content']//table//a").map { |episode| episode["href"] }.reverse
    end
    
    def rounds
      r_1_node, r_2_node = doc.xpath("//table[@class='round']")
      final_node = doc.xpath("//table[@class='final_round']").first
      
      rounds = []
      rounds[0] = Round.new(categories(r_1_node))
      rounds[1] = Round.new(categories(r_2_node))
      rounds[2] = Round.new(final_categories(final_node))
      rounds
    end

    def categories(node)
      category_names = node.xpath(".//td[@class='category_name']").map { |cat| cat.text }
      clue_nodes = node.xpath(".//td[@class='clue']")

      6.times.map do |i|
        Category.new(category_names[i], clues(clue_nodes, i))
      end
    end

    def final_categories(node)
      question = clean_question(node.xpath(".//div//@onmouseover")&.first&.value)
      answer = clean_answer (node.xpath(".//div//@onmouseout")&.first&.value)
      [Category.new("Final Jeopardy", Clue.new(question, answer, 0))]
    end

    def clues(clue_nodes, i)
      (i..29).step(6).map do |j|
        question = clean_question(clue_nodes[j].xpath(".//div//@onmouseover")&.first&.value)
        answer = clean_answer(clue_nodes[j].xpath(".//div//@onmouseout")&.first&.value)
        Clue.new(question, answer)
      end
    end

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
