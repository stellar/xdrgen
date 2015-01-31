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
  main
  comments
)

# setup node autloads 
grammars.each do |g|
  module_name = "xdr_#{g}_grammar".classify.to_sym
  autoload module_name, "xdrgen/grammar/#{g}_nodes"
end

# load the grammar files
grammars.each do |g|
  Treetop.load("#{__dir__}/grammar/#{g}.treetop")
end