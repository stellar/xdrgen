module Xdrgen
  class Generator
    attr_reader :result

    def initialize(top, output)
      @top    = top
      @output = output
    end

    def generate
      render_index
      render_definitions(@top)
    end

    def render_index
      # root_file_basename = File.basename(@output.source_path, ".x")
      # root_file = "#{root_file_basename}.rb"
      # out = @output.open(root_file)

      # render_autoloads(out, @top)
      # render_top_typedefs
    end

    def render_autoloads(out, node)
      out "module #{node.name.classify}"
      out.indent do 
        node.namespaces.each{ |n| render_autoloads(out, n) }
      end
      out "end"
    end

    def render_definitions(node)
      node.structs.each(&method(:render_struct))
      node.enums.each(&method(:render_enum))
      node.unions.each(&method(:render_union))

      node.namespaces.each{|ns| render_definitions(ns)}
    end

    def render_struct(struct)
      path = struct.fully_qualified_name.map(&:underscore).join("/") + ".rb"
      name = struct.fully_qualified_name.map(&:classify).join("::")

      out = @output.open(path)
      out.puts "class #{name}"
      out.indent do
        out.puts "include XDR::Struct"
        out.puts

        struct.members.each do |m|
          out.puts "attribute :#{m.name.underscore}, #{decl_string(m.declaration)}"
        end
      end
      out.puts "end"
    end

    def render_enum(enum)
      path = enum.fully_qualified_name.map(&:underscore).join("/") + ".rb"
      name = enum.fully_qualified_name.map(&:classify).join("::")

      out = @output.open(path)
      out.puts "module #{name}"
      out.indent do
        out.puts "include XDR::Enum"
        out.puts

        enum.members.each do |em|
          out.puts "#{em.name} = nil # TODO"
        end
      end
      out.puts "end"
    end

    def render_union(union)
      path = union.fully_qualified_name.map(&:underscore).join("/") + ".rb"
      name = union.fully_qualified_name.map(&:classify).join("::")

      out = @output.open(path)
      out.puts "class #{name}"
      out.indent do
        out.puts <<-EOS.strip_heredoc
          include XDR::Union
        
          discriminate #{union.discriminant_type}, :#{union.discriminant_name}
        EOS

        out.puts "# TODO"
        # union.arms.each do |a|
        #   a.cases.each do |c|
        #     value = "#{union.discriminant_type}::#{c}"
        #     out "arm :#{a.name.underscore}, #{value}, #{decl_string(a.declaration)}"
        #   end
        # end
      end
      out.puts "end"
    end

    private

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