module Xdrgen
  class Generator
    delegate :puts, to: :result
    attr_reader :result

    def generate(ast)
      @result = StringIO.new
      visit(ast)
      @result.string
    end

    def visit(ast)
      raise NotImplementedError
    end

    def visit_const_def(node)
      puts "#{node.name} = #{node.value}"
    end
  end
end