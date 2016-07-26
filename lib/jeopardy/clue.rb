require 'pry'

module Jeopardy 
  class Clue
    attr_accessor :question, :answer, :value
    
    def initialize(q, a, v=0)
      @question = q
      @answer = a
      @value = v
    end
  end
end
