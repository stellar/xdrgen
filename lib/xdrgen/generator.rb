module Xdrgen
  class Generator
    attr_reader :result

    def generate(top, output)
      @top    = top
      @output = output

      render_top
    end

    def render_top
      root_file_basename = File.basename(@output.source_path, ".x")
      root_file = "#{root_file_basename}.rb"
      out = @output.open(root_file)
    end

    def render_definitions(node)
      node.definition_blocks.each{|b| render_definition_block b}
    end

    def render_definition_block(definitions)
      return if definitions.blank?
      
      renderer =  case definitions.first
                  when AST::Definitions::Namespace ;
                    method(:render_namespace)
                  when AST::Definitions::Const ;
                    method(:render_const)
                  when AST::Definitions::Typedef ;
                    method(:render_typedef)
                  when AST::Definitions::Enum ;
                    method(:render_enum)
                  when AST::Definitions::Struct ;
                    method(:render_struct)
                  when AST::Definitions::Union ;
                    method(:render_union)
                  else
                    raise "Unknown definition type: #{klass}"
                  end

      definitions.each(&renderer)
      out
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
        out "include XDR::Struct"
        out
        struct.members.each do |m|
          out "attribute :#{m.name.underscore}, #{decl_string(m.declaration)}"
        end
      end
      out "end"
    end

    def render_enum(enum)
      out "module #{enum.name.classify}"
      indent do
        out "include XDR::Enum"
        out
        out "# TODO"
      end
      out "end"
    end

    def render_union(union)
      out "class #{union.name.classify}"
      indent do
        out "include XDR::Union"
        out
        out "discriminate #{union.discriminant_type}, :#{union.discriminant_name}"
        union.arms.each do |a|
          a.cases.each do |c|
            value = "#{union.discriminant_type}::#{c}"
            out "arm :#{a.name.underscore}, #{value}, #{decl_string(a.declaration)}"
          end
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

    def out(s="")
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
      when AST::Declarations::Void ;
        "XDR::Void"
      else
        raise "Unknown declaration type: #{decl.class.name}"
      end
    end

    def type_string(type)
      case type
      when AST::Typespecs::Int ;
        size_s = type.size.to_s.classify
        type.unsigned? ? "XDR::Unsigned#{size_s}" : "XDR::#{size_s}"
      when AST::Typespecs::Float ;
        size_s = type.size.to_s.classify
        "XDR::#{size_s}"
      when AST::Typespecs::Bool ;
        "XDR::Bool"
      else
        type.text_value.classify
      end
    end

  end
end