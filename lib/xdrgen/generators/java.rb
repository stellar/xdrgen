require 'set'

module Xdrgen
  module Generators

    class Java < Xdrgen::Generators::Base

      def generate
        render_lib
        render_definitions(@top)
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
      end

      def render_definitions(node)
        node.namespaces.each{|n| render_definitions n }
        node.definitions.each(&method(:render_definition))
      end

      def add_imports_for_definition(defn, imports)
        case defn
        when AST::Definitions::Struct ;
          defn.members.each do |m|
            if is_decl_array(m.declaration)
              imports.add('java.util.Arrays')
            else
              imports.add('com.google.common.base.Objects')
            end
          end
          # if we have more than one member field then the
          # hash code will be computed by
          # Objects.hashCode(field1, field2, ..., fieldN)
          # therefore, we should always import com.google.common.base.Objects
          if defn.members.length > 1
            imports.add("com.google.common.base.Objects")
          end
        when AST::Definitions::Enum ;
          # no imports required for enums
        when AST::Definitions::Union ;
          nonVoidArms = defn.arms.select { |arm| !arm.void? }
          # add 1 because of the discriminant
          totalFields = nonVoidArms.length + 1

          if is_type_array(defn.discriminant.type)
            imports.add('java.util.Arrays')
          else
            imports.add('com.google.common.base.Objects')
          end

          nonVoidArms.each do |a|
            if is_decl_array(a.declaration)
              imports.add('java.util.Arrays')
            else
              imports.add('com.google.common.base.Objects')
            end
          end

          # if we have more than one field then the
          # hash code will be computed by
          # Objects.hashCode(field1, field2, ..., fieldN)
          # therefore, we should always import com.google.common.base.Objects
          # if we have more than one field
          if totalFields > 1
            imports.add("com.google.common.base.Objects")
          end
        when AST::Definitions::Typedef ;
          if is_decl_array(defn.declaration)
            imports.add('java.util.Arrays')
          else
            imports.add('com.google.common.base.Objects')
          end
        end

        if defn.respond_to? :nested_definitions
          defn.nested_definitions.each{ |child_defn| add_imports_for_definition(child_defn, imports) }
        end
      end

      def render_definition(defn)
        imports = Set[]
        add_imports_for_definition(defn, imports)

        case defn
        when AST::Definitions::Struct ;
          render_element "public class", imports, defn do |out|
            render_struct defn, out
            render_nested_definitions defn, out
          end
        when AST::Definitions::Enum ;
          render_element "public enum", imports, defn do |out|
            render_enum defn, out
          end
        when AST::Definitions::Union ;
          render_element "public class", imports, defn do |out|
            render_union defn, out
            render_nested_definitions defn, out
          end
        when AST::Definitions::Typedef ;
          render_element "public class", imports, defn do |out|
            render_typedef defn, out
          end
        end
      end

      def render_nested_definitions(defn, out)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each{|ndefn|
          case ndefn
          when AST::Definitions::Struct ;
            name = name ndefn
            out.puts "public static class #{name} {"
            out.indent do
              render_struct ndefn, out
              render_nested_definitions ndefn , out
            end
            out.puts "}"
          when AST::Definitions::Enum ;
            name = name ndefn
            out.puts "public static enum #{name} {"
            out.indent do
              render_enum ndefn, out
            end
            out.puts "}"
          when AST::Definitions::Union ;
            name = name ndefn
            out.puts "public static class #{name} {"
            out.indent do
              render_union ndefn, out
              render_nested_definitions ndefn, out
            end
            out.puts "}"
          when AST::Definitions::Typedef ;
            name = name ndefn
            out.puts "public static class #{name} {"
            out.indent do
              render_typedef ndefn, out
            end
            out.puts "}"
          end
        }
      end

      def render_element(type, imports, element, post_name="implements XdrElement")
        path = element.name.camelize + ".java"
        name = name_string element.name
        out  = @output.open(path)
        render_top_matter out
        imports.each do |import|
          out.puts "import #{import};"
        end
        out.puts "\n"
        render_source_comment out, element
        out.puts "#{type} #{name} #{post_name} {"
        out.indent do
          yield out
          out.unbreak
        end
        out.puts "}"
      end

      def render_enum(enum, out)
        out.balance_after /,[\s]*/ do
          enum.members.each do |em|
            out.puts "#{em.name}(#{em.value}),"
          end
        end
        out.puts ";\n"
        out.puts <<-EOS.strip_heredoc
        private int mValue;

        #{name_string enum.name}(int value) {
            mValue = value;
        }

        public int getValue() {
            return mValue;
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
        out.break
      end

      def render_struct(struct, out)
        out.puts "public #{name struct} () {}"
        struct.members.each do |m|
          out.puts <<-EOS.strip_heredoc
            private #{decl_string(m.declaration)} #{m.name};
            public #{decl_string(m.declaration)} get#{m.name.slice(0,1).capitalize+m.name.slice(1..-1)}() {
              return this.#{m.name};
            }
            public void set#{m.name.slice(0,1).capitalize+m.name.slice(1..-1)}(#{decl_string m.declaration} value) {
              this.#{m.name} = value;
            }
          EOS
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

        hashCodeExpression = case struct.members.length
          when 0
            "0"
          when 1
            if is_decl_array(struct.members[0].declaration)
              "Arrays.hashCode(this.#{struct.members[0].name})"
            else
              "Objects.hashCode(this.#{struct.members[0].name})"
            end
          else
            "Objects.hashCode(#{
              (struct.members.map { |m|
                if is_decl_array(m.declaration)
                  "Arrays.hashCode(this.#{m.name})"
                else
                  "this.#{m.name}"
                end
              }).join(", ")
            })"
        end
        out.puts <<-EOS.strip_heredoc
          @Override
          public int hashCode() {
            return #{hashCodeExpression};
          }
        EOS

        equalParts = struct.members.map { |m|
          if is_decl_array(m.declaration)
            "Arrays.equals(this.#{m.name}, other.#{m.name})"
          else
            "Objects.equal(this.#{m.name}, other.#{m.name})"
          end
        }
        equalExpression = case equalParts.length
          when 0
            "true"
          else
            equalParts.join(" && ")
        end
        type = name struct
        out.puts <<-EOS.strip_heredoc
          @Override
          public boolean equals(Object object) {
            if (!(object instanceof #{type})) {
              return false;
            }

            #{type} other = (#{type}) object;
            return #{equalExpression};
          }

        EOS

        out.puts "public static final class Builder {"
        out.indent do
          struct.members.map { |m|
            out.puts "private #{decl_string(m.declaration)} #{m.name};"
          }

          struct.members.map { |m|
            out.puts <<-EOS.strip_heredoc

              public Builder #{m.name}(#{decl_string(m.declaration)} #{m.name}) {
                this.#{m.name} = #{m.name};
                return this;
              }
            EOS
          }

        end


        out.indent do
          out.break
          out.puts "public #{name struct} build() {"
          out.indent do
            out.puts "#{name struct} val = new #{name struct}();"
            struct.members.map { |m|
              out.puts "val.set#{m.name.slice(0,1).capitalize+m.name.slice(1..-1)}(#{m.name});"
            }
            out.puts "return val;"
          end
          out.puts "}"
        end
        out.puts "}"
        out.break
      end

      def render_typedef(typedef, out)
        out.puts <<-EOS.strip_heredoc
          private #{decl_string typedef.declaration} #{typedef.name};
          public #{decl_string typedef.declaration} get#{typedef.name.slice(0,1).capitalize+typedef.name.slice(1..-1)}() {
            return this.#{typedef.name};
          }
          public void set#{typedef.name.slice(0,1).capitalize+typedef.name.slice(1..-1)}(#{decl_string typedef.declaration} value) {
            this.#{typedef.name} = value;
          }
        EOS


        out.puts "public static void encode(XdrDataOutputStream stream, #{name typedef}  encoded#{name typedef}) throws IOException {"
        encode_member "encoded#{name typedef}", typedef, out
        out.puts "}"

        out.puts <<-EOS.strip_heredoc
          public void encode(XdrDataOutputStream stream) throws IOException {
            encode(stream, this);
          }
        EOS

        out.puts <<-EOS.strip_heredoc
          public static #{name typedef} decode(XdrDataInputStream stream) throws IOException {
            #{name typedef} decoded#{name typedef} = new #{name typedef}();
        EOS
        decode_member "decoded#{name typedef}", typedef, out
        out.indent do
          out.puts "return decoded#{name typedef};"
        end
        out.puts "}"

        hash_coder_for_decl =
          if is_decl_array(typedef.declaration)
            "Arrays.hashCode"
          else
            "Objects.hashCode"
          end
        out.puts <<-EOS.strip_heredoc
          @Override
          public int hashCode() {
            return #{hash_coder_for_decl}(this.#{typedef.name});
          }
        EOS

        equals_for_decl =
          if is_decl_array(typedef.declaration)
            "Arrays.equals"
          else
            "Objects.equal"
          end
        type = name_string typedef.name
        out.puts <<-EOS.strip_heredoc
          @Override
          public boolean equals(Object object) {
            if (!(object instanceof #{type})) {
              return false;
            }

            #{type} other = (#{type}) object;
            return #{equals_for_decl}(this.#{typedef.name}, other.#{typedef.name});
          }
        EOS
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
            private #{decl_string(arm.declaration)} #{arm.name};
            public #{decl_string(arm.declaration)} get#{arm.name.slice(0,1).capitalize+arm.name.slice(1..-1)}() {
              return this.#{arm.name};
            }
            public void set#{arm.name.slice(0,1).capitalize+arm.name.slice(1..-1)}(#{decl_string arm.declaration} value) {
              this.#{arm.name} = value;
            }
          EOS
        end
        out.break

        out.puts "public static final class Builder {"
        out.indent do
          out.puts "private #{type_string union.discriminant.type} discriminant;"
          union.arms.each do |arm|
            next if arm.void?
            out.puts "private #{decl_string(arm.declaration)} #{arm.name};"
          end
          out.break

          out.puts <<-EOS.strip_heredoc
            public Builder discriminant(#{type_string union.discriminant.type} discriminant) {
              this.discriminant = discriminant;
              return this;
            }
          EOS

          union.arms.each do |arm|
            next if arm.void?
            out.puts <<-EOS.strip_heredoc

              public Builder #{arm.name}(#{decl_string(arm.declaration)} #{arm.name}) {
                this.#{arm.name} = #{arm.name};
                return this;
              }
            EOS
          end
        end

        out.indent do
          out.break
          out.puts "public #{name union} build() {"
          out.indent do
            out.puts "#{name union} val = new #{name union}();"
            out.puts "val.setDiscriminant(discriminant);"
            union.arms.each do |arm|
              next if arm.void?
              out.puts "val.set#{arm.name.slice(0,1).capitalize+arm.name.slice(1..-1)}(#{arm.name});"
            end
            out.puts "return val;"
          end
          out.puts "}"
        end
        out.puts "}"
        out.break


        out.puts "public static void encode(XdrDataOutputStream stream, #{name union} encoded#{name union}) throws IOException {"
        out.puts('//' + union.discriminant.type.class.to_s)
        out.puts("//" + type_string(union.discriminant.type))
        if union.discriminant.type.is_a?(AST::Typespecs::Int)
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().intValue());"
        elsif type_string(union.discriminant.type) == "Uint32"
          # ugly workaround for compile error after generating source for AuthenticatedMessage in stellar-core
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().getUint32());"
        else
          out.puts "stream.writeInt(encoded#{name union}.getDiscriminant().getValue());"
        end
        if type_string(union.discriminant.type) == "Uint32"
          # ugly workaround for compile error after generating source for AuthenticatedMessage in stellar-core
          out.puts "switch (encoded#{name union}.getDiscriminant().getUint32()) {"
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
          out.puts "switch (decoded#{name union}.getDiscriminant().getUint32()) {"
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

        nonVoidArms = union.arms.select { |arm| !arm.void? }

        discriminantPart = if is_type_array(union.discriminant.type)
          "Arrays.hashCode(this.#{union.discriminant.name})"
        else
          "this.#{union.discriminant.name}"
        end

        parts = nonVoidArms.map { |a|
          if is_decl_array(a.declaration)
            "Arrays.hashCode(this.#{a.name})"
          else
            "this.#{a.name}"
          end
        }
        parts.append(discriminantPart)

        hashCodeExpression = "Objects.hashCode(#{parts.join(", ")})"
        out.puts <<-EOS.strip_heredoc
          @Override
          public int hashCode() {
            return #{hashCodeExpression};
          }
        EOS

        equalParts = nonVoidArms.map { |a|
          if is_decl_array(a.declaration)
            "Arrays.equals(this.#{a.name}, other.#{a.name})"
          else
            "Objects.equal(this.#{a.name}, other.#{a.name})"
          end
        }
        equalParts.append(
          if is_type_array(union.discriminant.type)
            "Arrays.equals(this.#{union.discriminant.name}, other.#{union.discriminant.name})"
          else
            "Objects.equal(this.#{union.discriminant.name}, other.#{union.discriminant.name})"
          end
        )

        equalExpression = case equalParts.length
          when 0
            "true"
          else
            equalParts.join(" && ")
        end
        type = name union
        out.puts <<-EOS.strip_heredoc
          @Override
          public boolean equals(Object object) {
            if (!(object instanceof #{type})) {
              return false;
            }

            #{type} other = (#{type}) object;
            return #{equalExpression};
          }
        EOS

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

        out.puts <<-EOS.strip_heredoc
        // === xdr source ============================================================

        EOS

        out.puts "//  " + defn.text_value.split("\n").join("\n//  ")

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
          "stream.writeInt(#{value})"
        when AST::Typespecs::Hyper ;
          "stream.writeLong(#{value})"
        when AST::Typespecs::UnsignedHyper ;
          "stream.writeLong(#{value})"
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
          "stream.readInt()"
        when AST::Typespecs::Hyper ;
          "stream.readLong()"
        when AST::Typespecs::UnsignedHyper ;
          "stream.readLong()"
        when AST::Typespecs::Float ;
          "stream.readFloat()"
        when AST::Typespecs::Double ;
          "stream.readDouble()"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in golang"
        when AST::Typespecs::Bool ;
          "stream.readInt() == 1 ? true : false"
        when AST::Typespecs::String ;
          "XdrString.decode(stream, #{decl.size})"
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
          "Integer"
        when AST::Typespecs::Hyper ;
          "Long"
        when AST::Typespecs::UnsignedHyper ;
          "Long"
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
    end
  end
end
