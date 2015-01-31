require 'treetop'
require 'xdrgen/grammar/nodes'

# load the grammar file
BASE_PATH = File.expand_path(File.dirname(__FILE__))
Treetop.load("#{BASE_PATH}/grammar.treetop")


module Xdrgen
  class Parser
    def initialize
      @grammar = XdrGrammarParser.new
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