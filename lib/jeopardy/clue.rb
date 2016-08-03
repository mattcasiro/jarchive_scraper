require 'pry'

module Jeopardy 
  class Clue
    include Comparable
    attr_accessor :question, :answer, :value
    
    def initialize(q, a, v=0)
      @question = q
      @answer = a
      @value = v
    end

    def <=>(other)
      self.value <=> other.value
    end
  end
end
