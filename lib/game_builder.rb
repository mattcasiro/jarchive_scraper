require 'pry'

class GameBuilder
  class DuplicateGameError < StandardError
  end

  attr_reader :games

  def initialize(num=1, user_paths=nil)
    raise ArgumentError, "Incorrect number of user_paths" if user_paths && user_paths.size != num
    sources = []
    scraper = Jeopardy::JArchiveScraper.new
    @games = (0...num).map do |i|
      # Add a unique game to the set
      tmp = next_game(scraper, i, user_paths)
      if sources.include? tmp.source
        raise DuplicateGameError if user_paths
        redo
      end
      sources.push tmp.source

      # Reduce game to three categories (one per round)
      begin
        [
          r1 = Jeopardy::CategorySelector.new(tmp.rounds[0]).category,
          r2 = Jeopardy::CategorySelector.new(tmp.rounds[1]).category,
          r3 = tmp.rounds[2].categories.first
        ]
      rescue ArgumentError => err
        raise err if user_paths
        redo
      end
    end
  end

  private
  def next_game(scraper, i, user_paths)
    begin
      user_paths ? scraper.new_game!(user_paths[i]) : scraper.new_game!
    rescue Jeopardy::MissingRoundError => err
      raise err if user_paths
      retry
    end
  end
end
