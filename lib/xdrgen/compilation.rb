module Xdrgen
  class Compilation
    extend Memoist

    def initialize(source_paths, output_dir:".", language: :ruby, generator: nil, namespace: nil, options: {})
      raise "An empty list of source paths (.x files) provided. At least one source file must be provided to compile." if source_paths.empty?
      @source_paths = source_paths
      @output_dir  = output_dir
      @namespace   = namespace
      @language    = language
      @generator   = generator
      @options     = options
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

      generator_class = @generator || Generators.for_language(@language)
      generator = generator_class.new(ast, output, @namespace, @options)
      generator.generate
    ensure
      output.close
    end
  end
end
