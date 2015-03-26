class Xdrgen::Generators::Base
  def initialize(top, output, namespace=nil)
    @top       = top
    @output    = output
    @namespace = namespace
  end

  def generate
    raise NotImplementedError
  end
end