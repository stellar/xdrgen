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

    def render_autoload(out, named, underneath=nil)
      name_parts =  if underneath
                      [underneath.name, named.name]
                    else
                      named.fully_qualified_name
                    end

      path = name_parts.map(&:underscore).join("/")
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
      render_element "class", struct, "< XDR::Struct" do |out|

        render_nested_definitions out, struct

        out.balance_after /,[\s]*/ do
          struct.members.each do |m|
            out.puts "attribute :#{m.name.underscore}, #{decl_string(m.declaration)}"
          end
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

      render_element "class", union, "< XDR::Union" do |out|
        render_nested_definitions out, union

        out.puts "switch_on #{union.discriminant_type}, :#{union.discriminant_name}"
        out.break

        out.balance_after /,[\s]*/ do
          union.arms.each do |a|
            case a
            when AST::Definitions::UnionArm ;
              a.cases.each do |c|
                value = "#{union.discriminant_type}::#{c}"

                if a.void?
                  out.puts "switch #{value}"
                else
                  out.puts "switch #{value}, :#{a.name.underscore}"
                end
              end
            when AST::Definitions::UnionDefaultArm ;
              out.puts "switch :default, :#{a.name.underscore}"
            end
          end
        end
        out.break

        out.balance_after /,[\s]*/ do
          union.arms.each do |a|
            next if a.void?
            out.puts "attribute :#{a.name.underscore}, #{decl_string(a.declaration)}"
          end
        end
      end
    end

    def render_nested_definitions(out, parent)
      ndefn = parent.nested_definitions
      ndefn.each(&method(:render_definition))

      out.balance_after /,[\s]*/ do
        ndefn.each{|n| render_autoload(out, n, parent)}
      end
      out.break
    end

    # TODO: find a better name
    # This renders the skeletal structure of enums, structs, and unions
    def render_element(type, element, post_name="")
      path               = element.fully_qualified_name.map(&:underscore).join("/") + ".rb"
      name               = element.name.classify
      out                = @output.open(path)
      render_top_matter out

      render_containers out, element.namespaces do
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


    def render_containers(out, containers, &block)
      cur = containers.first

      if cur.blank?
        block.call
        return
      end

      type =  case cur
              when AST::Definitions::Union, AST::Definitions::Struct ;
                "class"
              else
                "module"
              end

      out.puts "#{type} #{cur.name.classify}"
      out.indent do 
        render_containers(out, containers.drop(1), &block)
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
        "#{type}[#{args}]"
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