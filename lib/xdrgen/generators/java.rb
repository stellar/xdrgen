require 'set'

module Xdrgen
  module Generators
    class Java < Xdrgen::Generators::Base

      def generate
        constants_container = Set[]
        render_lib
        render_definitions(@top, constants_container)
        render_constants constants_container
      end

      def render_lib
        template = IO.read(__dir__ + "/java/XdrDataInputStream.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrDataInputStream.java", result

        template = IO.read(__dir__ + "/java/XdrDataOutputStream.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrDataOutputStream.java", result

        template = IO.read(__dir__ + "/java/XdrElement.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrElement.java", result

        template = IO.read(__dir__ + "/java/XdrString.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrString.java", result

        template = IO.read(__dir__ + "/java/XdrUnsignedHyperInteger.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrUnsignedHyperInteger.java", result

        template = IO.read(__dir__ + "/java/XdrUnsignedInteger.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrUnsignedInteger.java", result
      end

      def render_definitions(node, constants_container)
        node.namespaces.each{|n| render_definitions n, constants_container }
        node.definitions.each { |defn| render_definition(defn, constants_container) }
      end

      def add_imports_for_definition(defn, imports)
        imports.add("org.stellar.sdk.Base64Factory")
        imports.add("java.io.ByteArrayInputStream")
        imports.add("java.io.ByteArrayOutputStream")

        case defn
        when AST::Definitions::Struct, AST::Definitions::Union
          imports.add("lombok.Data")
          imports.add("lombok.NoArgsConstructor")
          imports.add("lombok.AllArgsConstructor")
          imports.add("lombok.Builder")
          imports.add("static #{@namespace}.Constants.*")
        when AST::Definitions::Typedef
          imports.add("lombok.Data")
          imports.add("lombok.NoArgsConstructor")
          imports.add("lombok.AllArgsConstructor")
          imports.add("static #{@namespace}.Constants.*")
        end

        if defn.respond_to? :nested_definitions
          defn.nested_definitions.each{ |child_defn| add_imports_for_definition(child_defn, imports) }
        end
      end

      def render_definition(defn, constants_container)
        imports = Set[]
        add_imports_for_definition(defn, imports)

        case defn
        when AST::Definitions::Struct ;
          render_element defn, imports, defn do |out|
            render_struct defn, out
            render_nested_definitions defn, out
          end
        when AST::Definitions::Enum ;
          render_element defn, imports, defn do |out|
            render_enum defn, out
          end
        when AST::Definitions::Union ;
          render_element defn, imports, defn do |out|
            render_union defn, out
            render_nested_definitions defn, out
          end
        when AST::Definitions::Typedef ;
          render_element defn, imports, defn do |out|
            render_typedef defn, out
          end
        when AST::Definitions::Const ;
          const_name = defn.name
          const_value = defn.value
          constants_container.add([const_name, const_value])
        end
      end

      def render_nested_definitions(defn, out, post_name="implements XdrElement")
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each{|ndefn|
          render_source_comment out, ndefn
          case ndefn
          when AST::Definitions::Struct ;
            name = name ndefn
            out.puts "@Data"
            out.puts "@NoArgsConstructor"
            out.puts "@AllArgsConstructor"
            out.puts "@Builder(toBuilder = true)"
            out.puts "public static class #{name} #{post_name} {"
            out.indent do
              render_struct ndefn, out
              render_nested_definitions ndefn , out
            end
            out.puts "}"
          when AST::Definitions::Enum ;
            name = name ndefn
            out.puts "public static enum #{name} #{post_name} {"
            out.indent do
              render_enum ndefn, out
            end
            out.puts "}"
          when AST::Definitions::Union ;
            name = name ndefn
            out.puts "@Data"
            out.puts "@NoArgsConstructor"
            out.puts "@AllArgsConstructor"
            out.puts "@Builder(toBuilder = true)"
            out.puts "public static class #{name} #{post_name} {"
            out.indent do
              render_union ndefn, out
              render_nested_definitions ndefn, out
            end
            out.puts "}"
          when AST::Definitions::Typedef ;
            name = name ndefn
            out.puts "@Data"
            out.puts "@NoArgsConstructor"
            out.puts "@AllArgsConstructor"
            out.puts "public static class #{name} #{post_name} {"
            out.indent do
              render_typedef ndefn, out
            end
            out.puts "}"
          end
        }
      end

      def render_element(defn, imports, element, post_name="implements XdrElement")
        path = element.name.camelize + ".java"
        name = name_string element.name
        out  = @output.open(path)
        render_top_matter out
        imports.each do |import|
          out.puts "import #{import};"
        end
        out.puts "\n"
        render_source_comment out, element
        case defn
        when AST::Definitions::Struct, AST::Definitions::Union
          out.puts "@Data"
          out.puts "@NoArgsConstructor"
          out.puts "@AllArgsConstructor"
          out.puts "@Builder(toBuilder = true)"
          out.puts "public class #{name} #{post_name} {"
        when AST::Definitions::Enum
          out.puts "public enum #{name} #{post_name} {"
        when AST::Definitions::Typedef
          out.puts "@Data"
          out.puts "@NoArgsConstructor"
          out.puts "@AllArgsConstructor"
          out.puts "public class #{name} #{post_name} {"
        end      
        out.indent do
          yield out
          out.unbreak
        end
        out.puts "}"
      end

      def render_constants(constants_container)
        out = @output.open("Constants.java")
        render_top_matter out
        out.puts "public final class Constants {"
        out.indent do
          out.puts "private Constants() {}"
          constants_container.each do |const_name, const_value|
            out.puts "public static final int #{const_name} = #{const_value};"
          end
        end
        out.puts "}"
      end

      def render_enum(enum, out)
        out.balance_after /,[\s]*/ do
          enum.members.each_with_index do |em, index|
            out.puts "#{em.name}(#{em.value})#{index == enum.members.size - 1 ? ';' : ','}"
          end
        end
        out.break
        out.puts <<-EOS.strip_heredoc
        private final int value;

        #{name_string enum.name}(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }

        public static #{name_string enum.name} decode(XdrDataInputStream stream) throws IOException {
          int value = stream.readInt();
          switch (value) {
        EOS
        out.indent 2 do
          enum.members.each do |em|
            out.puts "case #{em.value}: return #{em.name};"
          end
        end
        out.puts <<-EOS.strip_heredoc
            default:
              throw new RuntimeException("Unknown enum value: " + value);
          }
        }

        public static void encode(XdrDataOutputStream stream, #{name_string enum.name} value) throws IOException {
          stream.writeInt(value.getValue());
        }

        public void encode(XdrDataOutputStream stream) throws IOException {
          encode(stream, this);
        }
        EOS
        render_base64((name_string enum.name), out)
        out.break
      end

      def render_struct(struct, out)
        struct.members.each do |m|
          out.puts "private #{decl_string(m.declaration)} #{m.name};"
        end

        out.puts "public static void encode(XdrDataOutputStream stream, #{name struct} encoded#{name struct}) throws IOException{"
        struct.members.each do |m|
          out.indent do
            encode_member "encoded#{name struct}", m, out
          end
        end
        out.puts "}"

        out.puts <<-EOS.strip_heredoc
          public void encode(XdrDataOutputStream stream) throws IOException {
            encode(stream, this);
          }
        EOS

        out.puts <<-EOS.strip_heredoc
          public static #{name struct} decode(XdrDataInputStream stream) throws IOException {
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
        out.puts "}"

        render_base64((name struct), out)
        out.break
      end

      def render_typedef(typedef, out)
        out.puts "private #{decl_string typedef.declaration} #{typedef.name};"
        out.puts "public static void encode(XdrDataOutputStream stream, #{name typedef}  encoded#{name typedef}) throws IOException {"
        out.indent do
          encode_member "encoded#{name typedef}", typedef, out
        end
        out.puts "}"
        out.break

        out.puts <<-EOS.strip_heredoc
          public void encode(XdrDataOutputStream stream) throws IOException {
            encode(stream, this);
          }
        EOS

        out.puts <<-EOS.strip_heredoc
          public static #{name typedef} decode(XdrDataInputStream stream) throws IOException {
            #{name typedef} decoded#{name typedef} = new #{name typedef}();
        EOS
        out.indent do
          decode_member "decoded#{name typedef}", typedef, out
          out.puts "return decoded#{name typedef};"
        end
        out.puts "}"
        out.break
        render_base64(typedef.name.camelize, out)
      end

      def render_union(union, out)
        out.puts "private #{type_string union.discriminant.type} discriminant;"
        union.arms.each do |arm|
          next if arm.void?
          out.puts "private #{decl_string(arm.declaration)} #{arm.name};"
        end
        out.break

        out.puts "public static void encode(XdrDataOutputStream stream, #{name union} encoded#{name union}) throws IOException {"
        out.puts('//' + union.discriminant.type.class.to_s)
        out.puts("//" + type_string(union.discriminant.type))
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().intValue());"
        elsif type_string(union.discriminant.type) == "Uint32"
          # ugly workaround for compile error after generating source for AuthenticatedMessage in stellar-core
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().getUint32().getNumber().intValue());"
        else
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().getValue());"
        end
        if type_string(union.discriminant.type) == "Uint32"
          # ugly workaround for compile error after generating source for AuthenticatedMessage in stellar-core
          out.puts "switch (encoded#{name union}.getDiscriminant().getUint32().getNumber().intValue()) {"
        else
          out.puts "switch (encoded#{name union}.getDiscriminant()) {"
        end
        union.arms.each do |arm|
          case arm
            when AST::Definitions::UnionDefaultArm ;
              out.puts "default:"
            else
              arm.cases.each do |kase|
                if kase.value.is_a?(AST::Identifier)
                  if type_string(union.discriminant.type) == "Integer"
                    member = union.resolved_case(kase)
                    out.puts "case #{member.value}:"
                  else
                    out.puts "case #{kase.value.name}:"
                  end
                else
                  out.puts "case #{kase.value.value}:"
                end
              end
          end
          encode_member "encoded#{name union}", arm, out
          out.puts "break;"
        end
        out.puts "}\n}"
        out.puts <<-EOS.strip_heredoc
          public void encode(XdrDataOutputStream stream) throws IOException {
            encode(stream, this);
          }
        EOS

        out.puts "public static #{name union} decode(XdrDataInputStream stream) throws IOException {"
        out.puts "#{name union} decoded#{name union} = new #{name union}();"
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts "Integer discriminant = stream.readInt();"
        else
          out.puts "#{name union.discriminant.type} discriminant = #{name union.discriminant.type}.decode(stream);"
        end
        out.puts "decoded#{name union}.setDiscriminant(discriminant);"

        if type_string(union.discriminant.type) == "Uint32"
          # ugly workaround for compile error after generating source for AuthenticatedMessage in stellar-core
          out.puts "switch (decoded#{name union}.getDiscriminant().getUint32().getNumber().intValue()) {"
        else
          out.puts "switch (decoded#{name union}.getDiscriminant()) {"
        end

        union.arms.each do |arm|
          case arm
            when AST::Definitions::UnionDefaultArm ;
              out.puts "default:"
            else
              arm.cases.each do |kase|
                if kase.value.is_a?(AST::Identifier)
                  if type_string(union.discriminant.type) == "Integer"
                    member = union.resolved_case(kase)
                    out.puts "case #{member.value}:"
                  else
                    out.puts "case #{kase.value.name}:"
                  end
                else
                  out.puts "case #{kase.value.value}:"
                end
              end
          end
          decode_member "decoded#{name union}", arm, out
          out.puts "break;"
        end
        out.puts "}\n"
        out.indent do
          out.puts "return decoded#{name union};"
        end
        out.puts "}"
        render_base64((name union), out)
        out.break
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Automatically generated by xdrgen
          // DO NOT EDIT or your changes may be overwritten

          package #{@namespace};

          import java.io.IOException;
        EOS
        out.break
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts "/**"
        out.puts " * #{name defn}'s original definition in the XDR file is:"
        out.puts " * <pre>"
        out.puts " * " + escape_html(defn.text_value).split("\n").join("\n * ")
        out.puts " * </pre>"
        out.puts " */"
      end

      def render_base64(return_type, out)
        out.puts <<-EOS.strip_heredoc
          @Override
          public String toXdrBase64() throws IOException {
            return Base64Factory.getInstance().encodeToString(toXdrByteArray());
          }

          @Override
          public byte[] toXdrByteArray() throws IOException {
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            XdrDataOutputStream xdrDataOutputStream = new XdrDataOutputStream(byteArrayOutputStream);
            encode(xdrDataOutputStream);
            return byteArrayOutputStream.toByteArray();
          }

          public static #{return_type} fromXdrBase64(String xdr) throws IOException {
            byte[] bytes = Base64Factory.getInstance().decode(xdr);
            return fromXdrByteArray(bytes);
          }

          public static #{return_type} fromXdrByteArray(byte[] xdr) throws IOException {
            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(xdr);
            XdrDataInputStream xdrDataInputStream = new XdrDataInputStream(byteArrayInputStream);
            return decode(xdrDataInputStream);
          }
        EOS
      end

      def encode_member(value, member, out)
        case member.declaration
          when AST::Declarations::Void
            return
        end

        if member.type.sub_type == :optional
          out.puts "if (#{value}.#{member.name} != null) {"
          out.puts "stream.writeInt(1);"
        end
        case member.declaration
        when AST::Declarations::Opaque ;
          out.puts "int #{member.name}size = #{value}.#{member.name}.length;"
          unless member.declaration.fixed?
            out.puts "stream.writeInt(#{member.name}size);"
          end
          out.puts <<-EOS.strip_heredoc
            stream.write(#{value}.get#{member.name.slice(0,1).capitalize+member.name.slice(1..-1)}(), 0, #{member.name}size);
          EOS
        when AST::Declarations::Array ;
          out.puts "int #{member.name}size = #{value}.get#{member.name.slice(0,1).capitalize+member.name.slice(1..-1)}().length;"
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
          out.puts "} else {"
          out.puts "stream.writeInt(0);"
          out.puts "}"
        end
      end

      def encode_type(type, value)
        case type
        when AST::Typespecs::Int ;
          "stream.writeInt(#{value})"
        when AST::Typespecs::UnsignedInt ;
          "#{value}.encode(stream)"
        when AST::Typespecs::Hyper ;
          "stream.writeLong(#{value})"
        when AST::Typespecs::UnsignedHyper ;
          "#{value}.encode(stream)"
        when AST::Typespecs::Float ;
          "stream.writeFloat(#{value})"
        when AST::Typespecs::Double ;
          "stream.writeDouble(#{value})"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in golang"
        when AST::Typespecs::Bool ;
          "stream.writeInt(#{value} ? 1 : 0)"
        when AST::Typespecs::String ;
          "#{value}.encode(stream)"
        when AST::Typespecs::Simple ;
          "#{name type.resolved_type}.encode(stream, #{value})"
        when AST::Concerns::NestedDefinition ;
          "#{name type}.encode(stream, #{value})"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decode_member(value, member, out)
        case member.declaration
        when AST::Declarations::Void ;
          return
        end
        if member.type.sub_type == :optional
          out.puts <<-EOS.strip_heredoc
            int #{member.name}Present = stream.readInt();
            if (#{member.name}Present != 0) {
          EOS
        end
        case member.declaration
        when AST::Declarations::Opaque ;
          if (member.declaration.fixed?)
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = stream.readInt();"
          end
          out.puts <<-EOS.strip_heredoc
            #{value}.#{member.name} = new byte[#{member.name}size];
            stream.read(#{value}.#{member.name}, 0, #{member.name}size);
          EOS
        when AST::Declarations::Array ;
          if (member.declaration.fixed?)
            out.puts "int #{member.name}size = #{member.declaration.size};"
          else
            out.puts "int #{member.name}size = stream.readInt();"
          end
          out.puts <<-EOS.strip_heredoc
            #{value}.#{member.name} = new #{type_string member.type}[#{member.name}size];
            for (int i = 0; i < #{member.name}size; i++) {
              #{value}.#{member.name}[i] = #{decode_type member.declaration};
            }
          EOS
        else
          out.puts "#{value}.#{member.name} = #{decode_type member.declaration};"
        end
        if member.type.sub_type == :optional
          out.puts "}"
        end
      end

      def decode_type(decl)
        case decl.type
        when AST::Typespecs::Int ;
          "stream.readInt()"
        when AST::Typespecs::UnsignedInt ;
          "XdrUnsignedInteger.decode(stream)"
        when AST::Typespecs::Hyper ;
          "stream.readLong()"
        when AST::Typespecs::UnsignedHyper ;
          "XdrUnsignedHyperInteger.decode(stream)"
        when AST::Typespecs::Float ;
          "stream.readFloat()"
        when AST::Typespecs::Double ;
          "stream.readDouble()"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in golang"
        when AST::Typespecs::Bool ;
          "stream.readInt() == 1 ? true : false"
        when AST::Typespecs::String ;
          "XdrString.decode(stream, #{decl.size || 'Integer.MAX_VALUE'})"
        when AST::Typespecs::Simple ;
          "#{name decl.type.resolved_type}.decode(stream)"
        when AST::Concerns::NestedDefinition ;
          "#{name decl.type}.decode(stream)"
        else
          raise "Unknown typespec: #{decl.type.class.name}"
        end
      end

      def decl_string(decl)
        case decl
        when AST::Declarations::Opaque ;
          "byte[]"
        when AST::Declarations::String ;
          "XdrString"
        when AST::Declarations::Array ;
          "#{type_string decl.type}[]"
        when AST::Declarations::Optional ;
          "#{type_string(decl.type)}"
        when AST::Declarations::Simple ;
          type_string(decl.type)
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      def is_decl_array(decl)
        case decl
        when AST::Declarations::Opaque ;
          true
        when AST::Declarations::Array ;
          true
        when AST::Declarations::Optional ;
          is_type_array(decl.type)
        when AST::Declarations::Simple ;
        is_type_array(decl.type)
        else
          false
        end
      end

      def is_type_array(type)
        case type
        when AST::Typespecs::Opaque ;
          true
        else
          false
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Int ;
          "Integer"
        when AST::Typespecs::UnsignedInt ;
          "XdrUnsignedInteger"
        when AST::Typespecs::Hyper ;
          "Long"
        when AST::Typespecs::UnsignedHyper ;
          "XdrUnsignedHyperInteger"
        when AST::Typespecs::Float ;
          "Float"
        when AST::Typespecs::Double ;
          "Double"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in golang"
        when AST::Typespecs::Bool ;
          "Boolean"
        when AST::Typespecs::Opaque ;
          "Byte[#{type.size}]"
        when AST::Typespecs::String ;
          "XdrString"
        when AST::Typespecs::Simple ;
          name type.resolved_type
        when AST::Concerns::NestedDefinition ;
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

      def escape_html(value)
        value.to_s
             .gsub('&', '&amp;')
             .gsub('<', '&lt;')
             .gsub('>', '&gt;')
             .gsub('*', '&#42;') # to avoid encountering`*/`
      end
    end
  end
end
