module Xdrgen
  module Generators

    class Ruby < Xdrgen::Generators::Base

      def generate
        render_index
        render_definitions(@top)
      end

      private
      def render_index
        root_file = "#{@namespace}.rb"
        out = @output.open(root_file)
        render_top_matter out

        render_definitions_index(out, @top)
      end

      def render_definitions_index(out, node)

        node.definitions.each do |member|
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
      end

      def render_namespace_index(out, ns)
        out.puts "module #{name_string ns.name}"
        out.indent do
          out.puts "include XDR::Namespace"
          out.break
          render_definitions_index(out, ns)
          out.unbreak
        end
        out.puts "end"
      end

      def render_autoload(out, named)
        out.puts "autoload :#{name_string named.name}"
      end

      def render_typedef(out, typedef)
        out.puts "#{name_string typedef.name} = #{decl_string(typedef.declaration)}"
      end

      def render_const(out, const)
        out.puts "#{const.name.underscore.upcase} = #{const.value}"
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
        render_element "class", enum, "< XDR::Enum" do |out|
          out.balance_after /,[\s]*/ do
            enum.members.each do |em|
              out.puts "member :#{em.name.underscore}, #{em.value}"
            end
          end
          out.break
          out.puts "seal"
        end
      end

      def render_union(union)

        render_element "class", union, "< XDR::Union" do |out|
          render_nested_definitions out, union

          out.puts "switch_on #{type_string union.discriminant.type}, :#{union.discriminant_name}"
          out.break

          out.balance_after /,[\s]*/ do
            union.normal_arms.each do |arm|
              arm.cases.each do |c|
                value = c.value.text_value
                value = ":#{value.underscore}" if c.value.is_a?(AST::Identifier)
                render_union_switch(out, value, arm)
              end
            end

            if union.default_arm.present?
              render_union_switch(out, ":default", union.default_arm)
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

      def render_union_switch(out, switch, arm)
        if arm.void?
          out.puts "switch #{switch}"
        else
          out.puts "switch #{switch}, :#{arm.name.underscore}"
        end
      end

      def render_nested_definitions(out, parent)
        ndefn = parent.nested_definitions
        return if ndefn.empty?
        ndefn.each(&method(:render_definition))

        out.puts "include XDR::Namespace"
        out.break
        ndefn.each{|ndefn| render_autoload out, ndefn}
        out.break
      end

      # TODO: find a better name
      # This renders the skeletal structure of enums, structs, and unions
      def render_element(type, element, post_name="")
        path               = element.fully_qualified_name.map(&:underscore).join("/") + ".rb"
        name               = name_string element.name
        out                = @output.open(path)
        render_top_matter out
        render_source_comment out, element

        render_containers out, element.namespaces do
          out.puts "#{type} #{name} #{post_name}"
          out.indent do
            yield out
            out.unbreak
          end
          out.puts "end"
        end
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts <<-EOS.strip_heredoc
          # === xdr source ============================================================
          #
        EOS

        out.puts "#   " + defn.text_value.split("\n").join("\n#   ")

        out.puts <<-EOS.strip_heredoc
          #
          # ===========================================================================
        EOS
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          # This code was automatically generated using xdrgen
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

        out.puts "#{type} #{name_string cur.name}"
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
          args = [decl.child_type.to_s, decl.size].
            compact.
            map(&:to_s).
            join(", ")
          "#{type}[#{args}]"
        when AST::Declarations::Optional ;
          "XDR::Option[#{name_string decl.type.text_value}]"
        when AST::Declarations::Simple ;
          type_string(decl.type)
        when AST::Declarations::Void ;
          "XDR::Void"
        when AST::Concerns::NestedDefinition ;
          name_string type.name
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Int ;
          "XDR::Int"
        when AST::Typespecs::UnsignedInt ;
          "XDR::UnsignedInt"
        when AST::Typespecs::Hyper ;
          "XDR::Hyper"
        when AST::Typespecs::UnsignedHyper ;
          "XDR::UnsignedHyper"
        when AST::Typespecs::Float ;
          "XDR::Float"
        when AST::Typespecs::Double ;
          "XDR::Double"
        when AST::Typespecs::Quadruple ;
          "XDR::Quadruple"
        when AST::Typespecs::Bool ;
          "XDR::Bool"
        when AST::Typespecs::Simple ;
          name_string type.text_value
        when AST::Concerns::NestedDefinition ;
          name_string type.name
        else
          raise "Unknown type: #{type.class.name}"
        end
      end

      def name_string(name)
        name.camelize
      end

    end
  end
end
