module Xdrgen
  class Generator
    attr_reader :result

    def generate(top)
      @current_indent = 0
      @result = StringIO.new
      render_top(top)
      @result.string
    end

    def render_top(top)
      render_definitions(top)
    end

    def render_definitions(node)
      node.namespaces.each  {|n| render_namespace n}
      out ""
      node.typedefs.each    {|t| render_typedef t}
      out ""
      node.enums.each       {|e| render_struct e}
      out ""
      node.structs.each     {|s| render_struct s}
      out ""
      node.unions.each      {|u| render_union u}
    end

    def render_const(const)
      out "#{const.name} = #{const.value}"
    end

    def render_namespace(namespace)
      out "module #{namespace.name.classify}"
      indent do 
        render_definitions namespace
      end
      out "end"
    end

    def render_struct(struct)
      out "class #{struct.name.classify}"
      indent do
        struct.members.each do |m|
          out "attribute :#{m.name.underscore}, #{decl_string(m.declaration)}"
        end
      end
      out "end"
    end

    def render_typedef(typedef)
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
        raise "Unknown declaration type: #{decl.class.name}"
      end
    end

    def type_string(type)
      case type
      when AST::Typespecs::Int ;
        size_s = type.size.to_s.classify
        type.unsigned? ? "XDR::Unsigned#{size_s}" : "XDR::#{size_s}"
      else
        type.text_value.classify
      end
    end


  end
end