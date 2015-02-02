module Xdrgen
  class Compilation
    extend Memoist

    def initialize(source_path, output_dir)
      @source_path = source_path
      @output_dir  = output_dir
    end

    memoize def source
      IO.read(@source_path)
    end

    memoize def ast
      parser = Parser.new
      parser.parse(source)
    end

    def compile
      output = Output.new(@source_path, @output_dir)

      # TODO: make generator subclassable for different languages
      generator = Generator.new(ast, output)
      generator.generate
    ensure
      output.close
    end
  end
end