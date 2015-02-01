require 'pry'

module Xdrgen::CLI
  def self.run(args)
    parser   = Xdrgen::Parser.new
    generate = Xdrgen::Generator.new

    args.each do |file|
      raw         = IO.read(file)
      parsed      = parser.parse(raw)
      parsed.path = file
      code        = generate.generate(parsed)
      puts code
    end
  end
end