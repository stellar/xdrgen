require 'treetop'

module Xdrgen
  class Parser
    def initialize
      @grammar = XdrMainGrammarParser.new
    end
    
    def parse(data)
      @grammar.parse(data).tap do |tree|
        if(tree.nil?)
          raise Xdrgen::ParseError, "Couldn't parse, failed at offset: #{@grammar.index}"
        end
      end
    end
  end
end

grammars = %w(
  base
  enum
  const
  struct
  union
  typedef
  namespace
  comments
  main
)


# load the grammar files
grammars.each do |g|
  Treetop.load("#{__dir__}/grammar/#{g}.treetop")
end