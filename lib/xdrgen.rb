require "xdrgen/version"
require "active_support/dependencies/autoload"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"
require 'active_support/concern'

module Xdrgen
  extend ActiveSupport::Autoload

  autoload :CLI
  autoload :Generator
  autoload :Parser
  autoload :Util

  class ParseError < StandardError ; end
end
