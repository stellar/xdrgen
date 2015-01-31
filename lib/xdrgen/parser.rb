require 'treetop'
require 'xdrgen/grammar/nodes'

# Load our custom syntax node classes so the parser can use them
module Xdrgen
  BASE_PATH = File.expand_path(File.dirname(__FILE__))
  class Parser
    
    Treetop.load("#{BASE_PATH}/grammar.treetop")
    @@parser = XdrGrammarParser.new
    
    def self.parse(data)
      @@parser.parse(data).tap do |tree|
        if(tree.nil?)
          raise XdrGen::ParseError, "Couldn't parse, failed at offset: #{@@parser.index}"
        end
      end
    end
  end
end