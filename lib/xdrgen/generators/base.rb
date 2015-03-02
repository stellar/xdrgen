class Xdrgen::Generators::Base
  def initialize(top, output)
    @top    = top
    @output = output
  end

  def generate
    raise NotImplementedError
  end
end