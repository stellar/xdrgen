require "xdrgen/version"
require "active_support/all"
require 'memoist'

module Xdrgen
  extend ActiveSupport::Autoload

  autoload :Compilation
  autoload :AST
  autoload :CLI
  autoload :Generators
  autoload :Parser
  autoload :Util

  autoload :Output
  autoload :OutputFile

  class ParseError < StandardError ; end

  class GenerateError < StandardError ; end
  class DuplicateFileError < GenerateError ; end

  class TypeResolutionError < StandardError ; end
end
