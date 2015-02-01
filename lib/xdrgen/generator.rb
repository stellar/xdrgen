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
      recurse node.elements
    end

    def visit_const_def(const)
      out "#{const.name} = #{const.value}"
    end

    def visit_namespace_def(namespace)
      out "module #{namespace.name.classify}"
      indent do 
        recurse namespace.definitions
      end
      out "end"
    end

    def visit_typedef_def(typedef)
      out "#{typedef.name.classify} = #{decl_string(typedef.declaration)}"
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

    def recurse(children)
      children ||= []
      children.each{|c| visit(c)}
    end

    def decl_string(decl)
      case decl
      when AST::Declarations::Opaque ;
        type = decl.fixed? ? "XDR::Opaque" : "XDR::VarOpaque"
        "#{type}[#{decl.size}]"
      when AST::Declarations::String ;
        "XDR::String[#{decl.size}]"
      when AST::Declarations::Array ;
        type = decl.fixed? ? "XDR::Array" : "XDR::VarArray"
        args = [decl.child_type, decl.size].
          compact.
          map(&:to_s).
          join(", ")
        "XDR::Array[#{args}]"
      when AST::Declarations::Optional ;
        "XDR::Option[#{decl.child_type}]"
      when AST::Declarations::Simple ;
        type_string(decl.type)
      else
        "TODO"
      end
    end

    def type_string(type)
      case type
      when AST::Typespecs::Int ;
        size_s = type.size.to_s.classify
        type.unsigned? ? "XDR::Unsigned#{size_s}" : "XDR::#{size_s}"
      else
        type.text_value
      end
    end


  end
end