require 'treetop'

module Xdrgen
  class Parser
    delegate :failure_line, to: :@grammar

    def initialize
      @grammar = XdrMainGrammarParser.new
    end
    
    def parse(data)
      @grammar.parse(data).tap do |tree|
        if(tree.nil?)
          raise Xdrgen::ParseError, "Couldn't parse, failed at: #{@grammar.failure_line}:#{@grammar.failure_column}\n#{@grammar.failure_reason}"
        end
      end
    end


  end
end

grammars = %w(
  base
  declaration
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