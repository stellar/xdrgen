module Xdrgen
  module Generators

    class Rust < Xdrgen::Generators::Base

      def generate
        @already_rendered = []
        path = "#{@namespace}.rs"
        out = @output.open(path)

        render_top_matter out
        render_definitions(out, @top)
        #render_bottom_matter out
      end

      private

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Module #{@namepsace} is generated from:
          //
        EOS
        out.puts "//  #{@output.source_paths.join("\n//  ")}"
        out.puts <<-EOS.strip_heredoc
          //
          // DO NOT EDIT or your changes may be overwritten
          //! Stellar XDR types
          #![allow(dead_code)]
          use std::io::Write;
          #[allow(unused_imports)]
          use xdr_rs_serialize::de::{
                read_fixed_array, read_fixed_opaque, read_var_array, read_var_opaque, read_var_string,
                read_fixed_array_json, read_fixed_opaque_json, read_var_array_json, read_var_opaque_json, read_var_string_json,
                XDRIn,
          };
          use xdr_rs_serialize::error::Error;
          #[allow(unused_imports)]
          use xdr_rs_serialize::ser::{
                write_fixed_array, write_fixed_opaque, write_var_array, write_var_opaque, write_var_string,
                write_fixed_array_json, write_fixed_opaque_json, write_var_array_json, write_var_opaque_json, write_var_string_json,
                XDROut,
          };
        EOS
        out.break
      end

      def render_definitions(out, node)
        node.definitions.each{|n| render_definition out, n }
        node.namespaces.each{|n| render_definitions out, n }
      end

      def render_definition(out, defn)
        if @already_rendered.include? name(defn)

          unless defn.is_a?(AST::Definitions::Namespace)
            $stderr.puts "warn: #{name(defn)} is defined twice.  skipping"
          end

          return
        end

        render_nested_definitions(out, defn)
        render_source_comment(out, defn)

        @already_rendered << name(defn)

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

      def render_nested_definitions(out, defn)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each{|ndefn| render_definition out, ndefn}
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts <<-EOS.strip_heredoc
          // #{name defn} is an XDR #{defn.class.name.demodulize} defines as:
          //
        EOS

        out.puts "//   " + defn.text_value.split("\n").join("\n//    ")

        out.puts <<-EOS.strip_heredoc
          //
        EOS
      end

      def render_struct(out, struct)
        out.puts "#[derive(Clone, Debug, XDROut, XDRIn)]"
        out.puts "pub struct #{name struct} {"
        out.indent do
          struct.members.each do |m|
            render_struct_member(out, struct, m)
          end
        end
        out.puts "}"
        out.break
      end

      def render_struct_member(out, struct, m)
        render_type_decorator(out, m.declaration.type)
        out.puts "pub #{field_name m}: #{reference(m.declaration.type)},"
      end

      def render_enum(out, enum)
        out.puts "#[derive(Clone, Debug, XDROut, XDRIn)]"
        out.puts "pub enum #{name enum} {"
        out.indent do
          enum.members.each do |m|
            out.puts "#{name m} = #{m.value},"
          end
        end
        out.puts '}'
        out.break
      end

      def render_union(out, union)
        out.puts "// union"
        out.puts "#[derive(Clone, Debug, XDROut, XDRIn)]"
        out.puts "pub enum #{name union} {"
        out.indent do
          union.arms.each do |arm|
            case arm
            when AST::Definitions::UnionDefaultArm
                out.puts "// default"
                case_name = name arm
                out.puts "// #{union.discriminant.type}"
                out.puts arm.void? ? "#{case_name}," : "#{case_name}(#{reference arm.type}),"
            else
              arm.cases.each do |kase|
                  if kase.value.is_a?(AST::Identifier)
                    out.puts "// IDEN #{kase.value.name}"
                    case_name = kase.value.name.underscore.camelize
                  else
                    out.puts "// NO IDEN #{kase.value.value}"
                    case_name = "V#{kase.value.value}"
                  end
                  out.puts arm.void? ? "#{case_name}(())," : "#{case_name}(#{reference arm.type}),"
              end
            end
          end
        end
        out.puts '}'
        out.break
      end

      def render_typedef(out, typedef)
        out.puts "#[derive(Clone, Debug, XDROut, XDRIn)]"
        out.puts "pub struct #{name typedef} {"
        out.indent do
            render_typedef_decl(out, typedef)
        end
        out.puts "}"
        out.puts ""
        out.puts "impl #{name typedef} {"
        out.puts "    pub fn new(value: #{reference typedef.type}) -> #{name typedef} {"
        out.puts "        #{name typedef} { value }"
        out.puts "    }"
        out.puts "}"
        out.break
      end

      def render_typedef_decl(out, typedef)
        render_type_decorator(out, typedef.type)
        out.puts "pub value: #{reference typedef.type},"
      end

      def render_type_decorator(out, type)
        case type
        when AST::Typespecs::Opaque
          if type.fixed?
            out.puts "#[array(fixed = #{type.size})]"
          else
            out.puts "#[array(var = #{type.size})]"
          end
        when AST::Typespecs::String
          out.puts "#[array(var = #{type.size})]"
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          out.puts "// TODO"
        end
      end

      def render_const(out, const)
        out.puts "const #{name(const).underscore.upcase}: u64 = #{const.value};"
        out.break
      end

      def base_reference(type)
        case type
        when AST::Typespecs::Bool
          'bool'
        when AST::Typespecs::Double
          'f64'
        when AST::Typespecs::Float
          'f32'
        when AST::Typespecs::UnsignedHyper
          'u64'
        when AST::Typespecs::UnsignedInt
          'u32'
        when AST::Typespecs::Hyper
          'i64'
        when AST::Typespecs::Int
          'i32'
        when AST::Typespecs::Quadruple
          raise 'no quadruple support for rust'
        when AST::Typespecs::String
          'String'
        when AST::Typespecs::Opaque
          "Vec<u8>"
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          name type
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end
      end

      def reference(type)
        base_ref = base_reference type

        case type.sub_type
        when :simple
          base_ref
        when :optional
          "Option<#{base_ref}>"
        when :array
          is_named, size = type.array_size

          # if named, lookup the const definition
          if is_named
            size = name @top.find_definition(size)
          end

          "Vec<#{base_ref}>"
        when :var_array
          "Vec<#{base_ref}>"
        else
          raise "Unknown sub_type: #{type.sub_type}"
        end

      end

      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)

        base = if named.respond_to?(:name)
          named.name
        else
          named.text_value
        end
        base = escape_name(base)
        "#{parent}#{base.underscore.camelize}"
      end

      def field_name(named)
        escape_name named.name.underscore
      end

      def escape_name(name)
        case name
        when 'type' then 'type_'
        when 'Error' then 'SError'
        else name
        end
      end

    end
  end
end
