module Xdrgen
  class Generator
    attr_reader :result

    def generate(ast)
      @current_indent = 0
      @result = StringIO.new
      visit(ast)
      @result.string
    end

    def visit(node)
      @current_node = node

      name       = node.class.name.demodulize.underscore
      visit_name = "visit_#{name}".to_sym

      public_send(visit_name, node) if respond_to?(visit_name)
    end

    def visit_syntax_node(node)
      recurse
    end

    def visit_const_def(const)
      out "#{const.name} = #{const.value}"
    end

    def visit_namespace_def(namespace)
      out "module #{namespace.name.classify}"
      indent{ recurse }
      out "end"
    end

    def visit_typedef_def(typedef)
      
      result =  case typedef.declaration
                when AST::OpaqueDecl ;
                  name = typedef.name
                  size = typedef.declaration.size
                  "#{name} = XDR::Opaque[#{size}]"
                when AST::VarOpaqueDecl ;
                  size = typedef.declaration.max_size
                  "#{typedef.name} = XDR::VarOpaque[#{size}]"
                when AST::SimpleDecl ;
                  binding.pry
                else
                  "TODO = XDR::Int32 #TODO"
                end

      out result
    end

    private
    def indent
      @current_indent += 1
      yield
    ensure
      @current_indent -= 1
    end

    def out(s)
      indent         = "  " * @current_indent
      indented_lines = s.split("\n").map{|l| indent + l}

      @result.puts indented_lines.join("\n")
    end

    def recurse
      children = @current_node.elements || []
      children.each{|c| visit(c)}
    end
  end
end