require 'slop'

module Xdrgen
  module CLI
    def self.run(args)
      args = args.dup
      opts = Slop.parse! args do
        banner 'Usage: xdrgen -o OUTPUT_DIR INPUT'
        on 'o', 'output=', 'The ouput directory'
      end

      fail(opts) if args.blank?
      fail(opts) if opts[:output].blank?

      parser    = Parser.new
      generator = Generator.new

      args.each do |file|
        begin
          output      = Output.new(file, opts[:output])
          raw         = IO.read(file)
          parsed      = parser.parse(raw)
          generator.generate(parsed, output)
        ensure
          output.close
        end
      end
    end

    def self.fail(slop, code=1)
      STDERR.puts slop
      exit(code)
    end
  end
end