module Xdrgen
  module Generators
    class Csharp < Xdrgen::Generators::Base
      def generate
        render_definitions(@top)
      end

      def render_lib
        template = IO.read(__dir__ + "/csharp/ByteReader.erb")
        result = ERB.new(template).result binding
        @output.write  "ByteReader.cs", result

        template = IO.read(__dir__ + "/csharp/ByteWriter.erb")
        result = ERB.new(template).result binding
        @output.write  "ByteWriter.cs", result

        template = IO.read(__dir__ + "/csharp/IByteWriter.erb")
        result = ERB.new(template).result binding
        @output.write  "IByteWriter.cs", result

        template = IO.read(__dir__ + "/csharp/IByteReader.erb")
        result = ERB.new(template).result binding
        @output.write  "IByteReader.cs", result

        template = IO.read(__dir__ + "/csharp/XdrEncoding.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrEncoding.cs", result
      end

      def render_definitions(node)
        node.namespaces.each { |n| render_definitions n }
        node.definitions.each(&method(:render_definition))
      end

      def render_definition(defn)
        case defn
        when AST::Definitions::Struct
          render_element 'public struct', defn do |out|
            render_struct defn, out
            render_nested_definitions defn, out
          end
        when AST::Definitions::Enum
          render_element 'public class', defn do |out|
            render_enum defn, out
          end
        when AST::Definitions::Union
          render_element 'public class', defn do |out|
            render_union defn, out
            render_nested_definitions defn, out
          end
        when AST::Definitions::Typedef
          render_element 'public class', defn do |out|
            render_typedef defn, out
          end
        end
      end

      def render_nested_definitions(defn, out)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each do |ndefn|
          case ndefn
          when AST::Definitions::Struct
            name = name ndefn
            out.puts "public struct #{name} {"
            out.indent do
              render_struct ndefn, out
              render_nested_definitions ndefn, out
            end
            out.puts '}'
          when AST::Definitions::Enum
            name = name ndefn
            out.puts "public class #{name} {"
            out.indent do
              render_enum ndefn, out
            end
            out.puts '}'
          when AST::Definitions::Union
            name = name ndefn
            out.puts "public static class #{name} {"
            out.indent do
              render_union ndefn, out
              render_nested_definitions ndefn, out
            end
            out.puts '}'
          when AST::Definitions::Typedef
            name = name ndefn
            out.puts "public static class #{name} {"
            out.indent do
              render_typedef ndefn, out
            end
            out.puts '}'
          end
        end
      end

      def render_element(type, element, post_name = '')
        path = element.name.camelize + '.cs'
        name = name_string element.name
        out  = @output.open(path)
        render_top_matter out
        render_source_comment out, element

        out.puts "#{type} #{name} #{post_name} {"
        out.indent do
          yield out
          out.unbreak
        end
        out.puts '}'
        out.puts '}'
      end

      def render_enum(enum, out)
        enumname = enum.name + 'Enum'

        out.puts "public enum #{enumname} + 'Enum' {"
        out.balance_after /,[\s]*/ do
          enum.members.each do |em|
            out.puts "#{em.name} = #{em.value},"
          end
        end
        out.puts "}\n"
        out.puts <<-EOS.strip_heredoc
            public #{enumname} InnerValue {get; set;} = default(#{enumname})

            public static #{enum.name} Create(#{enumname} v)
            {
              return new #{enum.name} {
                InnerValue = v
              }
            }

            static #{name_string enum.name} Decode(IByteReader stream) {
              int value = XdrEncoding.DecodeInt32(stream);
              switch (value) {
            EOS
        out.indent 2 do
          enum.members.each do |em|
            out.puts "case #{em.value}: return Create(#{enumname}.#{em.name});"
          end
        end
        out.puts <<-EOS.strip_heredoc
                default:
                  throw new Exception("Unknown enum value: " + value);
              }
            }

            static void Encode(IByteWriter stream, #{name_string enum.name} value) {
              XdrEncoding.EncodeInt32((int)value.InnerValue, stream);
            }
            EOS
        out.break
      end

      def render_struct(struct, out)
        #out.puts "public #{name struct} () {}"
        struct.members.each do |m|
          out.puts <<-EOS.strip_heredoc
                public #{decl_string(m.declaration)} #{m.name.capitalize} {get; set;}
              EOS
        end

        out.puts "public static void encode(XdrDataOutputStream stream, #{name struct} encoded#{name struct}) {"
        struct.members.each do |m|
          out.indent do
            encode_member "encoded#{name struct}", m, out
          end
        end
        out.puts '}'

        out.puts <<-EOS.strip_heredoc
              public static #{name struct} decode(XdrDataInputStream stream) {
                #{name struct} decoded#{name struct} = new #{name struct}();
            EOS
        struct.members.each do |m|
          out.indent do
            decode_member "decoded#{name struct}", m, out
          end
        end
        out.indent do
          out.puts "return decoded#{name struct};"
        end
        out.puts '}'

        out.break
      end

      def render_typedef(typedef, out)
        out.puts <<-EOS.strip_heredoc
              public #{decl_string typedef.declaration} #{typedef.name.capitalize} {get; set;}
            EOS
        out.puts "public static void encode(XdrDataOutputStream stream, #{name typedef}  encoded#{name typedef}) {"
        encode_member "encoded#{name typedef}", typedef, out
        out.puts '}'

        out.puts <<-EOS.strip_heredoc
              public static #{name typedef} decode(XdrDataInputStream stream) {
                #{name typedef} decoded#{name typedef} = new #{name typedef}();
            EOS
        decode_member "decoded#{name typedef}", typedef, out
        out.indent do
          out.puts "return decoded#{name typedef};"
        end
        out.puts '}'
      end

      def render_union(union, out)
        out.puts "public #{name union} () {}"
        out.puts <<-EOS.strip_heredoc

              #{type_string union.discriminant.type} #{union.discriminant.name};
              public #{type_string union.discriminant.type} getDiscriminant() {
                return this.#{union.discriminant.name};
              }
              public void setDiscriminant(#{type_string union.discriminant.type} value) {
                this.#{union.discriminant.name} = value;
              }
            EOS
        union.arms.each do |arm|
          next if arm.void?
          out.puts <<-EOS.strip_heredoc
                public #{decl_string(arm.declaration)} #{arm.name.capitalize} {get; set;}
              EOS
        end

        out.puts "public static void encode(XdrDataOutputStream stream, #{name union} encoded#{name union}) {"
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().intValue());"
        # elsif [discriminant is AST::Definitions::Typedef]
        #   out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().get#{name union.discriminant.type}());"
        else
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().getValue());"
        end
        out.puts "switch (encoded#{name union}.getDiscriminant()) {"
        union.arms.each do |arm|
          case arm
          when AST::Definitions::UnionDefaultArm
            out.puts 'default:'
          else
            arm.cases.each do |kase|
              if kase.value.is_a?(AST::Identifier)
                out.puts "case #{kase.value.name}:"
              else
                out.puts "case #{kase.value.value}:"
              end
            end
          end
          encode_member "encoded#{name union}", arm, out
          out.puts 'break;'
        end
        out.puts "}\n}"

        out.puts "public static #{name union} decode(XdrDataInputStream stream) {"
        out.puts "#{name union} decoded#{name union} = new #{name union}();"
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts 'Integer discriminant = stream.readInt();'
        else
          out.puts "#{name union.discriminant.type} discriminant = #{name union.discriminant.type}.decode(stream);"
        end
        out.puts "decoded#{name union}.setDiscriminant(discriminant);"
        out.puts "switch (decoded#{name union}.getDiscriminant()) {"

        union.arms.each do |arm|
          case arm
          when AST::Definitions::UnionDefaultArm
            out.puts 'default:'
          else
            arm.cases.each do |kase|
              if kase.value.is_a?(AST::Identifier)
                out.puts "case #{kase.value.name}:"
              else
                out.puts "case #{kase.value.value}:"
              end
            end
          end
          decode_member "decoded#{name union}", arm, out
          out.puts 'break;'
        end
        out.puts "}\n"
        out.indent do
          out.puts "return decoded#{name union};"
        end
        out.puts '}'

        out.break
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
              // Automatically generated by xdrgen
              // DO NOT EDIT or your changes may be overwritten
              using System;

              namespace #{@namespace} {
            EOS
        out.break
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts <<-EOS.strip_heredoc
            // === xdr source ============================================================

            EOS

        out.puts '//  ' + defn.text_value.split("\n").join("\n//  ")

        out.puts <<-EOS.strip_heredoc

            //  ===========================================================================
            EOS
      end

      def encode_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void
          return
        end

        if member.type.sub_type == :optional
          out.puts "if (#{value}.#{member.name} != null) {"
          out.puts 'stream.writeInt(1);'
        end
        case member.declaration
        when AST::Declarations::Opaque
          out.puts "int #{member.name}size = #{value}.#{member.name}.length;"
          unless member.declaration.fixed?
            out.puts "stream.writeInt(#{member.name}size);"
          end
          out.puts <<-EOS.strip_heredoc
                stream.write(#{value}.get#{member.name.slice(0, 1).capitalize + member.name.slice(1..-1)}(), 0, #{member.name}size);
              EOS
        when AST::Declarations::Array
          out.puts "int #{member.name}size = #{value}.get#{member.name.slice(0, 1).capitalize + member.name.slice(1..-1)}().length;"
          unless member.declaration.fixed?
            out.puts "stream.writeInt(#{member.name}size);"
          end
          out.puts <<-EOS.strip_heredoc
                for (int i = 0; i < #{member.name}size; i++) {
                  #{encode_type member.declaration.type, "#{value}.#{member.name}[i]"};
                }
              EOS
        else
          out.puts "#{encode_type member.declaration.type, "#{value}.#{member.name}"};"
        end
        if member.type.sub_type == :optional
          out.puts '} else {'
          out.puts 'stream.writeInt(0);'
          out.puts '}'
        end
      end

      def encode_type(type, value)
        case type
        when AST::Typespecs::Int
          "stream.writeInt(#{value})"
        when AST::Typespecs::UnsignedInt
          "stream.writeInt(#{value})"
        when AST::Typespecs::Hyper
          "stream.writeLong(#{value})"
        when AST::Typespecs::UnsignedHyper
          "stream.writeLong(#{value})"
        when AST::Typespecs::Float
          "stream.writeFloat(#{value})"
        when AST::Typespecs::Double
          "stream.writeDouble(#{value})"
        when AST::Typespecs::Quadruple
          raise 'cannot render quadruple in golang'
        when AST::Typespecs::Bool
          "stream.writeInt(#{value} ? 1 : 0)"
        when AST::Typespecs::String
          "stream.writeString(#{value})"
        when AST::Typespecs::Simple
          "#{name type.resolved_type}.encode(stream, #{value})"
        when AST::Concerns::NestedDefinition
          "#{name type}.encode(stream, #{value})"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decode_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void
          return
        end
        if member.type.sub_type == :optional
          out.puts <<-EOS.strip_heredoc
                int #{member.name}Present = stream.readInt();
                if (#{member.name}Present != 0) {
              EOS
        end
        case member.declaration
        when AST::Declarations::Opaque
          if member.declaration.fixed?
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = stream.readInt();"
          end
          out.puts <<-EOS.strip_heredoc
                #{value}.#{member.name} = new byte[#{member.name}size];
                stream.read(#{value}.#{member.name}, 0, #{member.name}size);
              EOS
        when AST::Declarations::Array
          if member.declaration.fixed?
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = stream.readInt();"
          end
          out.puts <<-EOS.strip_heredoc
                #{value}.#{member.name} = new #{type_string member.type}[#{member.name}size];
                for (int i = 0; i < #{member.name}size; i++) {
                  #{value}.#{member.name}[i] = #{decode_type member.declaration.type};
                }
              EOS
        else
          out.puts "#{value}.#{member.name} = #{decode_type member.declaration.type};"
        end
        out.puts '}' if member.type.sub_type == :optional
      end

      def decode_type(type)
        case type
        when AST::Typespecs::Int
          'stream.readInt()'
        when AST::Typespecs::UnsignedInt
          'stream.readInt()'
        when AST::Typespecs::Hyper
          'stream.readLong()'
        when AST::Typespecs::UnsignedHyper
          'stream.readLong()'
        when AST::Typespecs::Float
          'stream.readFloat()'
        when AST::Typespecs::Double
          'stream.readDouble()'
        when AST::Typespecs::Quadruple
          raise 'cannot render quadruple in golang'
        when AST::Typespecs::Bool
          'stream.readInt() == 1 ? true : false'
        when AST::Typespecs::String
          'stream.readString()'
        when AST::Typespecs::Simple
          "#{name type.resolved_type}.decode(stream)"
        when AST::Concerns::NestedDefinition
          "#{name type}.decode(stream)"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decl_string(decl)
        case decl
        when AST::Declarations::Opaque
          'byte[]'
        when AST::Declarations::String
          'String'
        when AST::Declarations::Array
          "#{type_string decl.type}[]"
        when AST::Declarations::Optional
          type_string(decl.type).to_s
        when AST::Declarations::Simple
          type_string(decl.type)
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Int
          'int'
        when AST::Typespecs::UnsignedInt
          'uint'
        when AST::Typespecs::Hyper
          'long'
        when AST::Typespecs::UnsignedHyper
          'long'
        when AST::Typespecs::Float
          'float'
        when AST::Typespecs::Double
          'double'
        when AST::Typespecs::Quadruple
          'Tuple'
        when AST::Typespecs::Bool
          'bool'
        when AST::Typespecs::Opaque
          "Byte[#{type.size}]"
        when AST::Typespecs::Simple
          name type.resolved_type
        when AST::Concerns::NestedDefinition
          name type
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)
        result = named.name.camelize

        "#{parent}#{result}"
      end

      def name_string(name)
        name.camelize
      end
    end
  end
end
