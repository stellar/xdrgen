module Xdrgen
  module Generators
    class Csharp < Xdrgen::Generators::Base
      def generate
        render_lib
        render_definitions(@top)
      end

      def render_lib
        template = IO.read(__dir__ + '/csharp/ByteReader.erb')
        result = ERB.new(template).result binding
        @output.write 'ByteReader.cs', result

        template = IO.read(__dir__ + '/csharp/ByteWriter.erb')
        result = ERB.new(template).result binding
        @output.write 'ByteWriter.cs', result

        template = IO.read(__dir__ + '/csharp/IByteWriter.erb')
        result = ERB.new(template).result binding
        @output.write 'IByteWriter.cs', result

        template = IO.read(__dir__ + '/csharp/IByteReader.erb')
        result = ERB.new(template).result binding
        @output.write 'IByteReader.cs', result

        template = IO.read(__dir__ + '/csharp/XdrEncoding.erb')
        result = ERB.new(template).result binding
        @output.write 'XdrEncoding.cs', result
      end

      def render_definitions(node)
        node.namespaces.each { |n| render_definitions n }
        node.definitions.each(&method(:render_definition))
      end

      def render_definition(defn)
        case defn
        when AST::Definitions::Struct
          render_element 'public class', defn do |out|
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
            out.puts "public class #{name} {"
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
            out.puts "public class #{name} {"
            out.indent do
              render_union ndefn, out
              render_nested_definitions ndefn, out
            end
            out.puts '}'
          when AST::Definitions::Typedef
            name = name ndefn
            out.puts "public class #{name} {"
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

        out.puts "public enum #{enumname} {"
        out.balance_after /,[\s]*/ do
          enum.members.each do |em|
            out.puts "#{em.name} = #{em.value},"
          end
        end
        out.puts "}\n"
        out.puts <<-EOS.strip_heredoc
            public #{enumname} InnerValue {get; set;} = default(#{enumname});

            public static #{enum.name} Create(#{enumname} v)
            {
              return new #{enum.name} {
                InnerValue = v
              };
            }

            public static #{name_string enum.name} Decode(IByteReader stream) {
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

            public static void Encode(IByteWriter stream, #{name_string enum.name} value) {
              XdrEncoding.EncodeInt32((int)value.InnerValue, stream);
            }
            EOS
        out.break
      end

      def render_struct(struct, out)
        out.puts "public #{name struct} () {}"
        struct.members.each do |m|
          out.puts <<-EOS.strip_heredoc
                public #{decl_string(m.declaration)} #{m.name.camelize} {get; set;}
              EOS
        end
        out.puts "\n"
        out.puts "public static void Encode(IByteWriter stream, #{name struct} encoded#{name struct}) {"
        struct.members.each do |m|
          out.indent do
            encode_member "encoded#{name struct}", m, out
          end
        end
        out.puts '}'

        out.puts <<-EOS.strip_heredoc
              public static #{name struct} Decode(IByteReader stream) {
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
              public #{decl_string typedef.declaration} InnerValue {get; set;} = default(#{decl_string typedef.declaration});

              public #{typedef.name.camelize}() {}

              public #{typedef.name.camelize}(#{decl_string typedef.declaration} value)
              {
                InnerValue = value;
              }

            EOS
        out.puts "public static void Encode(IByteWriter stream, #{name typedef}  encoded#{name typedef}) {"
        encode_innervalue_member "encoded#{name typedef}", typedef, out
        out.puts '}'

        out.puts <<-EOS.strip_heredoc
              public static #{name typedef} Decode(IByteReader stream) {
                #{name typedef} decoded#{name typedef} = new #{name typedef}();
            EOS
        decode_innervalue_member "decoded#{name typedef}", typedef, out
        out.indent do
          out.puts "return decoded#{name typedef};"
        end
        out.puts '}'
      end

      def render_union(union, out)
        has_inner_value = false

        out.puts "public #{name union} () {}"
        out.puts <<-EOS.strip_heredoc

              #{type_string union.discriminant.type} Discriminant { get; set; } = new #{type_string union.discriminant.type}();

            EOS
        union.arms.each do |arm|
          next if arm.void?
          out.puts <<-EOS.strip_heredoc
                public #{decl_string(arm.declaration)} #{arm.name.camelize} {get; set;}
              EOS
        end

        out.puts "public static void Encode(IByteWriter stream, #{name union} encoded#{name union}) {"
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts "XdrEncoding.EncodeInt32((int)encoded#{name union}.Discriminant, stream);"
          out.puts "switch (encoded#{name union}.Discriminant) {"
        # elsif [discriminant is AST::Definitions::Typedef]
        #   out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().get#{name union.discriminant.type}());"
        else
          has_inner_value = true
          out.puts "XdrEncoding.EncodeInt32((int)encoded#{name union}.Discriminant.InnerValue, stream);"
          out.puts "switch (encoded#{name union}.Discriminant.InnerValue) {"
        end

        union.arms.each do |arm|
          case arm
          when AST::Definitions::UnionDefaultArm
            out.puts 'default:'
          else
            arm.cases.each do |kase|
              if kase.value.is_a?(AST::Identifier)
                out.puts "case #{type_string union.discriminant.type}.#{type_string union.discriminant.type}Enum.#{kase.value.name}:"
              else
                out.puts "case #{kase.value.value}:"
              end
            end
          end
          encode_member "encoded#{name union}", arm, out
          out.puts 'break;'
        end
        out.puts "}\n}"

        out.puts "public static #{name union} Decode(IByteReader stream) {"
        out.puts "#{name union} decoded#{name union} = new #{name union}();"
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts 'int discriminant =  XdrEncoding.DecodeInt32(stream);'
          out.puts "decoded#{name union}.Discriminant = discriminant;"
          out.puts "switch (decoded#{name union}.Discriminant) {"
        else
          out.puts "#{name union.discriminant.type} discriminant = #{name union.discriminant.type}.Decode(stream);"
          out.puts "decoded#{name union}.Discriminant = discriminant;"
          out.puts "switch (decoded#{name union}.Discriminant.InnerValue) {"
        end

        union.arms.each do |arm|
          case arm
          when AST::Definitions::UnionDefaultArm
            out.puts 'default:'
          else
            arm.cases.each do |kase|
              if kase.value.is_a?(AST::Identifier)
                out.puts "case #{type_string union.discriminant.type}.#{type_string union.discriminant.type}Enum.#{kase.value.name}:"
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

      def encode_innervalue_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void
          return
        end

        if member.type.sub_type == :optional
          out.puts "if (#{value}.InnerValue != null) {"
          out.puts 'XdrEncoding.EncodeInt32(1, stream);'
        end

        case member.declaration
        when AST::Declarations::Opaque
          out.puts "int #{member.name}size = #{value}.InnerValue.Length;"
          unless member.declaration.fixed?
            out.puts "XdrEncoding.EncodeInt32(#{member.name.camelize}size, stream);"
          end
          out.puts <<-EOS.strip_heredoc
                XdrEncoding.WriteFixOpaque(stream, (uint)#{member.name}size, #{value}.InnerValue);
              EOS
        when AST::Declarations::Array
          out.puts "int #{member.name}size = #{value}.InnerValue.Length;"
          unless member.declaration.fixed?
            out.puts "XdrEncoding.EncodeInt32(#{member.name}size, stream);"
          end
          out.puts <<-EOS.strip_heredoc
                for (int i = 0; i < #{member.name}size; i++) {
                  #{encode_type member.declaration.type, "#{value}.InnerValue[i]"};
                }
              EOS
        else
          out.puts "#{encode_type member.declaration.type, "#{value}.InnerValue"};"
        end
        if member.type.sub_type == :optional
          out.puts '} else {'
          out.puts 'XdrEncoding.EncodeInt32(0, stream);'
          out.puts '}'
        end
      end

      def encode_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void
          return
        end

        if member.type.sub_type == :optional
          out.puts "if (#{value}.#{member.name.camelize} != null) {"
          out.puts 'XdrEncoding.EncodeInt32(1, stream);'
        end
        case member.declaration
        when AST::Declarations::Opaque
          out.puts "int #{member.name}size = #{value}.#{member.name.camelize}.Length;"
          unless member.declaration.fixed?
            out.puts "XdrEncoding.EncodeInt32(#{member.name.camelize}size, stream);"
          end
          out.puts <<-EOS.strip_heredoc
                XdrEncoding.WriteFixOpaque(stream, (uint)#{member.name}size, #{value}.#{member.name.camelize});
              EOS
        when AST::Declarations::Array
          out.puts "int #{member.name}size = #{value}.#{member.name.camelize}.Length;"
          unless member.declaration.fixed?
            out.puts "XdrEncoding.EncodeInt32(#{member.name}size, stream);"
          end
          out.puts <<-EOS.strip_heredoc
                for (int i = 0; i < #{member.name}size; i++) {
                  #{encode_type member.declaration.type, "#{value}.#{member.name.camelize}[i]"};
                }
              EOS
        else
          out.puts "#{encode_type member.declaration.type, "#{value}.#{member.name.camelize}"};"
        end
        if member.type.sub_type == :optional
          out.puts '} else {'
          out.puts 'XdrEncoding.EncodeInt32(0, stream);'
          out.puts '}'
        end
      end

      def encode_type(type, value)
        case type
        when AST::Typespecs::Int
          "XdrEncoding.EncodeInt32(#{value}, stream)"
        when AST::Typespecs::UnsignedInt
          "XdrEncoding.EncodeUInt32(#{value}, stream)"
        when AST::Typespecs::Hyper
          "XdrEncoding.EncodeInt64(#{value}, stream)"
        when AST::Typespecs::UnsignedHyper
          "XdrEncoding.EncodeUInt64(#{value}, stream)"
        when AST::Typespecs::Float
          "XdrEncoding.EncodeSingle(#{value}, stream)"
        when AST::Typespecs::Double
          "XdrEncoding.EncodeDouble(#{value}, stream)"
        when AST::Typespecs::Quadruple
          raise 'cannot render quadruple in golang'
        when AST::Typespecs::Bool
          "XdrEncoding.WriteBool(stream, #{value})"
        when AST::Typespecs::String
          "XdrEncoding.WriteString(stream, #{value})"
        when AST::Typespecs::Simple
          "#{name type.resolved_type}.Encode(stream, #{value})"
        when AST::Concerns::NestedDefinition
          "#{name type}.Encode(stream, #{value})"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decode_innervalue_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void
          return
        end
        if member.type.sub_type == :optional
          out.puts <<-EOS.strip_heredoc
                int #{member.name.camelize}Present = XdrEncoding.DecodeInt32(stream);
                if (#{member.name.camelize}Present != 0) {
              EOS
        end
        case member.declaration
        when AST::Declarations::Opaque
          if member.declaration.fixed?
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = XdrEncoding.DecodeInt32(stream);"
          end
          out.puts <<-EOS.strip_heredoc
                #{value}.InnerValue = new byte[#{member.name}size];
                XdrEncoding.ReadFixOpaque(stream, (uint)#{member.name}size);
              EOS
        when AST::Declarations::Array
          if member.declaration.fixed?
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = XdrEncoding.DecodeInt32(stream);"
          end
          out.puts <<-EOS.strip_heredoc
                #{value}.InnerValue = new #{type_string member.type}[#{member.name}size];
                for (int i = 0; i < #{member.name}size; i++) {
                  #{value}.InnerValue[i] = #{decode_type member.declaration.type};
                }
              EOS
        else
          out.puts "#{value}.InnerValue = #{decode_type member.declaration.type};"
        end
        out.puts '}' if member.type.sub_type == :optional
      end

      def decode_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void
          return
        end
        if member.type.sub_type == :optional
          out.puts <<-EOS.strip_heredoc
                int #{member.name.camelize}Present = XdrEncoding.DecodeInt32(stream);
                if (#{member.name.camelize}Present != 0) {
              EOS
        end
        case member.declaration
        when AST::Declarations::Opaque
          if member.declaration.fixed?
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = XdrEncoding.DecodeInt32(stream);"
          end
          out.puts <<-EOS.strip_heredoc
                #{value}.#{member.name.camelize} = new byte[#{member.name}size];
                  XdrEncoding.ReadFixOpaque(stream, (uint)#{member.name}size);
              EOS
        when AST::Declarations::Array
          if member.declaration.fixed?
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = XdrEncoding.DecodeInt32(stream);"
          end
          out.puts <<-EOS.strip_heredoc
                #{value}.#{member.name.camelize} = new #{type_string member.type}[#{member.name}size];
                for (int i = 0; i < #{member.name}size; i++) {
                  #{value}.#{member.name.camelize}[i] = #{decode_type member.declaration.type};
                }
              EOS
        else
          out.puts "#{value}.#{member.name.camelize} = #{decode_type member.declaration.type};"
        end
        out.puts '}' if member.type.sub_type == :optional
      end

      def decode_type(type)
        case type
        when AST::Typespecs::Int
          'XdrEncoding.DecodeInt32(stream)'
        when AST::Typespecs::UnsignedInt
          'XdrEncoding.DecodeUInt32(stream)'
        when AST::Typespecs::Hyper
          'XdrEncoding.DecodeInt64(stream)'
        when AST::Typespecs::UnsignedHyper
          'XdrEncoding.DecodeUInt64(stream)'
        when AST::Typespecs::Float
          'XdrEncoding.DecodeSingle(stream)'
        when AST::Typespecs::Double
          'XdrEncoding.DecodeDouble(stream)'
        when AST::Typespecs::Quadruple
          raise 'cannot render quadruple in golang'
        when AST::Typespecs::Bool
          'XdrEncoding.ReadBool(stream)'
        when AST::Typespecs::String
          'XdrEncoding.ReadString(stream)'
        when AST::Typespecs::Simple
          "#{name type.resolved_type}.Decode(stream)"
        when AST::Concerns::NestedDefinition
          "#{name type}.Decode(stream)"
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
          'ulong'
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
