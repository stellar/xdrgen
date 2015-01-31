require 'pry'

module Xdrgen::CLI
  def self.run(args)
    parser   = Xdrgen::Parser.new
    generate = Xdrgen::Generator.new

    args.each do |file|
      raw     = IO.read(file)
      parsed  = parser.parse(raw)
      code    = generate.generate(parsed)
      binding.pry
    end
  end
end