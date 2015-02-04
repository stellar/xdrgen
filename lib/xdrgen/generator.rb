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
      root_file_basename = File.basename(@output.source_path, ".x")
      root_file = "#{root_file_basename}.rb"
      out = @output.open(root_file)
      render_top_matter out

      render_definitions_index(out, @top)
    end

    def render_definitions_index(out, node)

      node.definition_blocks.each do |block|
        block.each do |member|
          case member
          when AST::Definitions::Namespace ;
            render_namespace_index(out, member)
          when AST::Definitions::Typedef ;
            render_typedef(out, member)
          when AST::Definitions::Const ;
            render_const(out, member)
          when AST::Definitions::Struct,
               AST::Definitions::Union,
               AST::Definitions::Enum ;
            render_autoload(out, member)
          end
        end

        out.break
      end
    end

    def render_namespace_index(out, ns)
      out.puts "module #{ns.name.classify}"
      out.indent do 
        render_definitions_index(out, ns)
        out.unbreak
      end
      out.puts "end"
    end

    def render_autoload(out, named)
      path = named.fully_qualified_name.map(&:underscore).join("/")
      out.puts "autoload :#{named.name.classify}, \"\#{__dir__}/#{path}\""
    end

    def render_typedef(out, typedef)
      out.puts "#{typedef.name.classify} = #{decl_string(typedef.declaration)}"
    end

    def render_const(out, const)
      out.puts "#{const.name.classify} = #{const.value}"
    end

    def render_definitions(node)
      node.definitions.each(&method(:render_definition))
      node.namespaces.each(&method(:render_definitions))
    end

    def render_definition(defn)
      case defn
      when AST::Definitions::Struct ;
        render_struct defn
      when AST::Definitions::Enum ;
        render_enum defn
      when AST::Definitions::Union ;
        render_union defn
      end
    end

    def render_struct(struct)
      ndefn = struct.nested_definitions
      ndefn.each(&method(:render_definition))

      render_element "class", struct, "< XDR::Struct" do |out|
        out.break
        ndefn.each{|n| render_autoload(out,n)}
        out.break

        struct.members.each do |m|
          out.puts "attribute :#{m.name.underscore}, #{decl_string(m.declaration)}"
        end
      end
    end

    def render_enum(enum)
      render_element "module", enum do |out|
        out.puts "include XDR::Enum"
        out.break

        out.balance_after /[^=]+/ do
          enum.members.each do |em|
            out.puts "#{em.name.underscore.upcase} = #{em.value}"
          end
        end
      end
    end

    def render_union(union)
      ndefn = union.nested_definitions
      ndefn.each(&method(:render_definition))

      render_element "class", union, "< XDR::Union" do |out|
        out.puts "switch_on #{union.discriminant_type}, :#{union.discriminant_name}"

        out.break
        ndefn.each{|n| render_autoload(out,n)}
        out.break

        union.arms.each do |a|
          case a
          when AST::Definitions::UnionArm ;
            a.cases.each do |c|
              value = "#{union.discriminant_type}::#{c}"
              out.puts "switch #{value}, :#{a.name.underscore}"
            end
          when AST::Definitions::UnionDefaultArm ;
            out.puts "switch :default, :#{a.name.underscore}"
          end
        end
        out.break

        union.arms.each do |a|
          out.puts "attribute :#{a.name.underscore}, #{decl_string(a.declaration)}"
        end
      end
    end

    # TODO: find a better name
    # This renders the skeletal structure of enums, structs, and unions
    def render_element(type, element, post_name="")
      path               = element.fully_qualified_name.map(&:underscore).join("/") + ".rb"
      name               = element.name.classify
      containing_modules = element.namespaces.map{|ns| ns.name.classify }
      out                = @output.open(path)
      render_top_matter out

      render_nested_modules out, containing_modules do
        out.puts "#{type} #{name} #{post_name}"
        out.indent do 
          yield out
          out.unbreak
        end
        out.puts "end"
      end
    end

    def render_top_matter(out)
      out.puts <<-EOS.strip_heredoc
        # Automatically generated from #{@output.source_path}
        # DO NOT EDIT or your changes may be overwritten
      
        require 'xdr'
      EOS
      out.break
    end


    def render_nested_modules(out, modules, &block)
      cur = modules.first

      if cur.blank?
        block.call
        return
      end

      out.puts "module #{cur}"
      out.indent do 
        render_nested_modules(out, modules.drop(1), &block)
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
        args = [decl.child_type.classify, decl.size].
          compact.
          map(&:to_s).
          join(", ")
        "XDR::Array[#{args}]"
      when AST::Declarations::Optional ;
        "XDR::Option[#{decl.child_type.classify}]"
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
      when AST::Concerns::NestedDefinition ;
        type.name.classify
      else
        type.text_value.classify
      end
    end

  end
end