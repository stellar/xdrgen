module Xdrgen
  module Generators

    class Javascript < Xdrgen::Generators::Base

      def generate
        path = "#{@namespace}_generated.js"
        out = @output.open(path)

        render_top_matter out
        render_define_block(out) do
          render_definitions(out, @top)
        end
      end

      private
      def render_definitions(out, node)
        node.definitions.each{|n| render_definition out, n }
        node.namespaces.each{|n| render_definitions out, n }
      end

      def render_nested_definitions(out, defn)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each{|ndefn| render_definition out, ndefn}
      end

      def render_definition(out, defn)
        render_nested_definitions(out, defn)
        render_source_comment(out, defn)

        case defn
        when AST::Definitions::Struct ;
          render_struct out, defn
        when AST::Definitions::Enum ;
          render_enum out, defn
        when AST::Definitions::Union ;
          render_union out, defn
        when AST::Definitions::Typedef ;
          render_typedef out, defn
        when AST::Definitions::Const ;
          render_const out, defn
        end
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts <<-EOS.strip_heredoc
          // === xdr source ============================================================
          //
        EOS

        out.puts "//   " + defn.text_value.split("\n").join("\n//   ")

        out.puts <<-EOS.strip_heredoc
          //
          // ===========================================================================
        EOS
      end


      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Automatically generated on #{Time.now.iso8601}
          // DO NOT EDIT or your changes may be overwritten
        
          import * as XDR from 'xdr';
        EOS
        out.break
      end

      def render_define_block(out)
        out.puts "var types = XDR.define(xdr => {"
        yield
      ensure
        out.puts "});"
        out.puts "export default types;"
        out.break
      end


      def render_typedef(out, typedef)
        out.puts "xdr.typedef(\"#{name typedef}\", #{reference typedef.declaration.type});"
        out.break
      end

      def render_const(out, const)
        out.puts "xdr.const(\"#{const_name const}\", #{const.value});"
        out.break
      end

      def render_struct(out, struct)
        out.puts "//TODO"
      end

      def render_enum(out, enum)
        out.puts "xdr.enum(\"#{name enum}\", {"

        out.indent do
          enum.members.each do |m|
            out.puts "#{enum_member_name m}: #{m.value},"
          end
        end

        out.puts "});"
        out.break
      end

      def render_union(out, union)
        out.puts "//TODO"
      end

      private
      def decl(decl)
        # TODO
      end

      def type(type)
        # TODO
      end

      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)

        # NOTE: classify will strip plurality, so we restore it if necessary
        plural = named.name.pluralize == named.name
        base   = named.name.underscore.classify
        result = plural ? base.pluralize : base

        "#{parent}#{result}"
      end

      def const_name(named)
        # NOTE: classify will strip plurality, so we restore it if necessary
        plural = named.name.pluralize == named.name
        base   = named.name.underscore.upcase
        plural ? base.pluralize : base
      end

      def enum_member_name(member)
        name(member).camelize(:lower)
      end

      def reference(type)
        baseReference = case type
        when AST::Typespecs::Opaque
          "xdr.opaque(#{type.size})"
        else
          raise "Unknown reference type: #{type.class.name}"
        end
      end

    end
  end
end