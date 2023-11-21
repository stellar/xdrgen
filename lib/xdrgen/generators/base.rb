class Xdrgen::Generators::Base
  def initialize(top, output, namespace=nil, options={})
    @top       = top
    @output    = output
    @namespace = namespace
    @options   = options
  end

  def generate
    raise NotImplementedError
  end
end
