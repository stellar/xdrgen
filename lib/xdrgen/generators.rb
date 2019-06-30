module Xdrgen::Generators
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Ruby
  autoload :Go
  autoload :Javascript
  autoload :Java
  autoload :Scala

  def self.for_language(language)
    const_get language.to_s.classify
  rescue NameError
    raise ArgumentError, "Unsupported language: #{language}"
  end
end
