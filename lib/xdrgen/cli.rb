require 'slop'

module Xdrgen
  module CLI
    def self.run(args)
      args = args.dup
      opts = Slop.parse! args do
        banner 'Usage: xdrgen -o OUTPUT_DIR INPUT --gen=ruby'
        on 'o', 'output=', 'The ouput directory'
        on 'l', 'language=', 'The ouput language', default: 'ruby'
      end

      fail(opts) if args.blank?
      fail(opts) if opts[:output].blank?

      compilations = args.map{|f| Compilation.new(f, opts[:output], opts[:language].to_sym)}

      compilations.each(&:compile)
    end

    def self.fail(slop, code=1)
      STDERR.puts slop
      exit(code)
    end
  end
end