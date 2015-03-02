require "xdrgen/version"
require "active_support/dependencies/autoload"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/string/indent"
require "active_support/core_ext/string/strip"
require 'active_support/concern'
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
end
