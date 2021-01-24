module Xdrgen
  module Generators
    class Elixir < Xdrgen::Generators::Base
      MAX_INT = (2**31) - 1
      def generate
        path = "#{@namespace}_generated.ex"
        out = @output.open(path)

        render_define_block(out) do
          out.indent() do
            render_definitions(out, @top)
          end
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
          comment ~S"""
          === xdr source ============================================================

        EOS

        out.puts "    " + defn.text_value.split("\n").join("\n    ")

        out.puts <<-EOS.strip_heredoc

          ===========================================================================
          """
        EOS
      end

      def render_moduledoc(out)
        out.puts <<-EOS.strip_heredoc
          @moduledoc """
          Automatically generated on #{Time.now.iso8601}
          DO NOT EDIT or your changes may be overwritten

          Target implementation: exdr at https://hex.pm/packages/exdr
          """
        EOS
        out.break
      end

      def render_define_block(out)
        out.puts "defmodule #{@namespace} do"
        out.indent do
          render_moduledoc(out)
          out.puts "use XDR.Base\n\n"
        end
        yield
      ensure
        out.puts "end"
        out.break
      end


      def render_typedef(out, typedef)
        out.puts "define_type(\"#{name typedef}\", #{build_type_args typedef.declaration.type})"
      end

      def render_const(out, const)
        out.puts "define_type(\"#{const_name const}\", Const, #{const.value});"
      end

      def render_struct(out, struct)
        out.puts "define_type(\"#{name struct}\", Struct,"
        out.indent do
          struct.members.each_with_index do |m, i|
            out.puts "#{member_name m}: #{type_reference m.type}#{comma_unless_last(i, struct.members)}"
          end
        end
        out.puts ")"
      end

      def render_enum(out, enum)
        out.puts "define_type(\"#{name enum}\", Enum,"
        out.indent do
          enum.members.each_with_index do |m, i|
            out.puts "#{member_name m}: #{m.value}#{comma_unless_last(i, enum.members)}"
          end
        end
        out.puts ")"
      end

      def render_union(out, union)
        out.puts "define_type(\"#{name union}\", Union,"
        out.indent do
          out.puts "switch_type: #{type_reference union.discriminant.type},"
          out.puts "switch_name: :#{member_name union.discriminant},"

          out.puts "switches: ["
          out.indent do
            union.normal_arms.each do |arm|
              arm_name = arm.void? ? "XDR.Type.Void" : ":#{member_name(arm)}"

              arm.cases.each do |acase|
                switch = if acase.value.is_a?(AST::Identifier)
                  ":#{member_name(acase.value)}"
                else
                  acase.value.text_value
                end

                out.puts "{#{switch}, #{arm_name}},"
              end
            end
          end
          out.puts "],"

          out.puts "arms: ["
          out.indent do
            union.arms.each do |arm|
              next if arm.void?
              out.puts "#{member_name arm}: #{type_reference arm.type},"
            end
          end
          out.puts union.default_arm.present? ? "]," : "]"

          if union.default_arm.present?
            arm = union.default_arm
            arm_name = arm.void? ? "XDR.Type.Void" : member_name(arm)
            out.puts "default_arm: #{arm_name},"
          end
        end
        out.puts ")"
      end

      private
      def name(named)
        return nil unless named.respond_to?(:name)

        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)

        # NOTE: classify will strip plurality, so we restore it if necessary
        plural = named.name.downcase.pluralize == named.name.downcase
        base   = named.name.underscore.classify
        result = plural ? base.pluralize : base

        "#{parent}#{result}"
      end

      def const_name(named)
        named.name.underscore.upcase
      end

      def member_name(member)
        name(member).underscore
      end

      # this can be a string to reference a custom type
      # or a build_type call like build_type(VariableOpaque, 100)
      # args for build_type can be created with build_type_args
      def type_reference(type)
        build_args = build_type_args(type)

        build_args === "\"#{name type}\"" ? build_args : "build_type(#{build_args})"
      end

      def comma_unless_last(index, collection)
        if index + 1 >= collection.length
          ""
        else
          ","
        end
      end

      # the args to supply build_type (or define_type(name, ...args))
      def build_type_args(type)
        base_ref = case type
          when AST::Typespecs::Bool
            "Bool"
          when AST::Typespecs::Double
            "Double"
          when AST::Typespecs::Float
            "Float"
          when AST::Typespecs::Hyper
            "HyperInt"
          when AST::Typespecs::Int
            "Int"
          when AST::Typespecs::Opaque
            if type.fixed?
              "Opaque, #{type.size}"
            else
              type.size ? "VariableOpaque, #{type.size}" : "VariableOpaque"
            end
          when AST::Typespecs::Quadruple
            raise "no quadruple support in elixir"
          when AST::Typespecs::String
            "XDR.Type.String, #{type.size}"
          when AST::Typespecs::UnsignedHyper
            "UnsignedHyperInt"
          when AST::Typespecs::UnsignedInt
            "UnsignedInt"
          when AST::Typespecs::Simple
            "\"#{name type}\""
          when AST::Definitions::Base
            "\"#{name type}\""
          when AST::Concerns::NestedDefinition
            "\"#{name type}\""
          else
            raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end

        base_type = base_ref === "\"#{name type}\"" ? base_ref : "buid_type(base_ref)"

        case type.sub_type
          when :simple
            base_ref
          when :optional
            "Optional, #{base_type}"
          when :array
            is_named, size = type.array_size
            size = is_named ? "\"#{size}\"" : size
            "Array, length: #{size}, type: #{base_type}"
          when :var_array
            is_named, size = type.array_size
            size = is_named ? "\"#{size}\"" : (size || MAX_INT)
            "VariableArray, max_length: #{size}, type: #{base_type}"
          else
            raise "Unknown sub_type: #{type.sub_type}"
        end
      end
    end
  end
end
