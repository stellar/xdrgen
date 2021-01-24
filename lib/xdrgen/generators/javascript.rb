module Xdrgen
  module Generators

    class Javascript < Xdrgen::Generators::Base
      MAX_INT = (2**31) - 1
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

        out.break
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

          /* jshint maxstatements:2147483647  */
          /* jshint esnext:true  */

          import * as XDR from 'js-xdr';

        EOS
        out.break
      end

      def render_define_block(out)
        out.puts "var types = XDR.config(xdr => {"
        yield
      ensure
        out.puts "});"
        out.puts "export default types;"
        out.break
      end


      def render_typedef(out, typedef)
        out.puts "xdr.typedef(\"#{name typedef}\", #{reference typedef.declaration.type});"
      end

      def render_const(out, const)
        out.puts "xdr.const(\"#{const_name const}\", #{const.value});"
      end

      def render_struct(out, struct)
        out.puts "xdr.struct(\"#{name struct}\", ["
        out.indent do
          struct.members.each do |m|
            out.puts "[\"#{member_name m}\", #{reference m.type}],"
          end
        end
        out.puts "]);"
      end

      def render_enum(out, enum)
        out.puts "xdr.enum(\"#{name enum}\", {"

        out.indent do
          enum.members.each do |m|
            out.puts "#{member_name m}: #{m.value},"
          end
        end

        out.puts "});"
      end

      def render_union(out, union)
        out.puts "xdr.union(\"#{name union}\", {"
        out.indent do
          out.puts "switchOn: #{reference union.discriminant.type},"
          out.puts "switchName: \"#{member_name union.discriminant}\","
          out.puts "switches: ["

          out.indent do
            union.normal_arms.each do |arm|
              arm_name = arm.void? ? "xdr.void()" : "\"#{member_name(arm)}\""

              arm.cases.each do |acase|
                switch = if acase.value.is_a?(AST::Identifier)
                  if union.discriminant.type.is_a?(AST::Typespecs::Int)
                    member = union.resolved_case(acase)
                    "#{member.value}"
                  else
                    '"' + member_name(acase.value) + '"'
                  end
                else
                  acase.value.text_value
                end

                out.puts "[#{switch}, #{arm_name}],"
              end
            end
          end

          out.puts "],"
          out.puts "arms: {"

          out.indent do
            union.arms.each do |arm|
              next if arm.void?
              out.puts "#{member_name arm}: #{reference arm.type},"
            end
          end

          out.puts "},"

          if union.default_arm.present?
            arm = union.default_arm
            arm_name = arm.void? ? "xdr.void()" : member_name(arm)
            out.puts "defaultArm: #{arm_name},"
          end

        end
        out.puts "});"
      end

      private
      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)

        # NOTE: classify will strip plurality, so we restore it if necessary
        #
        # Downcase the value since pluralize adds a lower case `s`.
        #
        # Without downcasing, the following appears as singular, but it's plural:
        #
        #  "BEGIN_SPONSORING_FUTURE_RESERVEs" == "BEGIN_SPONSORING_FUTURE_RESERVES"
        #  => false
        #
        plural = named.name.downcase.pluralize == named.name.downcase
        base   = named.name.underscore.classify
        result = plural ? base.pluralize : base

        "#{parent}#{result}"
      end

      def const_name(named)
        named.name.underscore.upcase
      end

      def member_name(member)
        name(member).camelize(:lower)
      end

      def reference(type)
        baseReference = case type
        when AST::Typespecs::Bool
          "xdr.bool()"
        when AST::Typespecs::Double
          "xdr.double()"
        when AST::Typespecs::Float
          "xdr.float()"
        when AST::Typespecs::Hyper
          "xdr.hyper()"
        when AST::Typespecs::Int
          "xdr.int()"
        when AST::Typespecs::Opaque
          if type.fixed?
            "xdr.opaque(#{type.size})"
          else
            "xdr.varOpaque(#{type.size})"
          end
        when AST::Typespecs::Quadruple
          raise "no quadruple support for javascript"
        when AST::Typespecs::String
          "xdr.string(#{type.size})"
        when AST::Typespecs::UnsignedHyper
          "xdr.uhyper()"
        when AST::Typespecs::UnsignedInt
          "xdr.uint()"
        when AST::Typespecs::Simple
          "xdr.lookup(\"#{name type}\")"
        when AST::Definitions::Base
          "xdr.lookup(\"#{name type}\")"
        when AST::Concerns::NestedDefinition
          "xdr.lookup(\"#{name type}\")"
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end

        case type.sub_type
        when :simple
          baseReference
        when :optional
          "xdr.option(#{baseReference})"
        when :array
          is_named, size = type.array_size
          size = is_named ? "xdr.lookup(\"#{size}\")" : size
          "xdr.array(#{baseReference}, #{size})"
        when :var_array
          is_named, size = type.array_size
          size = is_named ? "xdr.lookup(\"#{size}\")" : (size || MAX_INT)
          "xdr.varArray(#{baseReference}, #{size})"
        else
          raise "Unknown sub_type: #{type.sub_type}"
        end

      end

    end
  end
end
