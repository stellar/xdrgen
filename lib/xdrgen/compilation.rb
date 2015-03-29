module Xdrgen
  class Compilation
    extend Memoist

    def initialize(source_paths, output_dir:".", language: :ruby, namespace: nil)
      @source_paths = source_paths
      @output_dir  = output_dir
      @namespace   = namespace
      @language    = language
    end

    memoize def source
     @source_paths.map{|p| IO.read(p)}.join("\n")
    end

    memoize def ast
      parser = Parser.new
      parser.parse(source)
    end

    def compile
      output = Output.new(@source_paths, @output_dir)

      
      generator = Generators.for_language(@language).new(ast, output, @namespace)
      generator.generate
    ensure
      output.close
    end
  end
end