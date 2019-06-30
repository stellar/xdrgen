module Xdrgen
  module Generators

    class Scala < Xdrgen::Generators::Base

      def generate
        render_lib
        render_definitions(@top)
      end

      def render_lib
        template = IO.read(__dir__ + "/scala/XdrDataInputStream.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrDataInputStream.scala", result

        template = IO.read(__dir__ + "/scala/XdrDataOutputStream.erb")
        result = ERB.new(template).result binding
        @output.write  "XdrDataOutputStream.scala", result
      end

      def render_definitions(node)
        node.namespaces.each{|n| render_definitions n }
        node.definitions.each(&method(:render_definition))
      end

      def render_definition(defn)
        case defn
        when AST::Definitions::Struct ;
          render_file defn do |out|
            render_struct defn, out
          end
        when AST::Definitions::Enum ;
          render_file defn do |out|
            render_enum defn, out
          end
        when AST::Definitions::Union ;
          render_file defn do |out|
            render_union defn, out
          end
        when AST::Definitions::Typedef ;
          render_file defn do |out|
            render_typedef defn, out
          end
        end
      end

      def render_file(element)
        path = element.name.camelize + ".scala"
        out  = @output.open(path)
        render_top_matter out
        render_source_comment out, element

        yield out
      end

      def render_nested_definitions(defn, out)
        return unless defn.respond_to? :nested_definitions
        unless defn.nested_definitions.empty?
          out.puts ""
        end
        defn.nested_definitions.each{|ndefn|
          case ndefn
          when AST::Definitions::Struct ;
            name = name ndefn
            render_struct ndefn, out
          when AST::Definitions::Enum ;
            name = name ndefn
            render_enum ndefn, out
          when AST::Definitions::Union ;
            name = name ndefn
            render_union ndefn, out
          when AST::Definitions::Typedef ;
            name = name ndefn
            render_typedef ndefn, out
          end
        }
      end

      def render_enum(enum, out)
        name = name_string enum.name
        out.puts <<-EOS.strip_heredoc
          sealed class #{name} (val i: Int) {
            def encode(stream: XdrDataOutputStream) = stream.writeInt(i)
          }

          object #{name} {
            def decode(stream: XdrDataInputStream): #{name} = stream.readInt() match {
        EOS
        out.indent do
          out.indent do
            enum.members.each do |em|
               out.puts("case #{em.value} => #{name_string em.name}")
            end
            out.puts("case i => throw new IllegalArgumentException(s\"#{name} value $i is invalid\")")
          end
          out.puts "}"
          out.puts ""
          enum.members.each do |em|
            out.puts <<-EOS.strip_heredoc
            case object #{name_string em.name} extends #{name}(#{em.value})
            EOS
          end

          render_nested_definitions enum, out
        end
        out.puts "}"
      end

      def render_struct(element, out)
        name = name_string element.name
        out.puts "case class #{name} ("
        out.indent do
            len = element.members.length
            element.members.each do |m|
                out.puts "#{sanitize m.name}: " + (is_nested?(m.type) ? "#{name}." : "") + "#{decl_string m.declaration}" + (len > 1 ? ", " : "")
              len -= 1
            end
        end
        out.puts ") {"
        out.indent do
          out.puts "def encode(stream: XdrDataOutputStream): Unit = {"
          out.indent do
            element.members.each do |m|
              encode_member m, out
            end
          end
        end
        out.puts "  }"
        out.puts "}"
        out.puts ""
        out.puts "object #{name} {"
        out.puts "  def decode(stream: XdrDataInputStream): #{name} = #{name element}("
        out.indent do
          out.indent do
            len = element.members.length
            element.members.each do |m|
              decode_member m, out, len == 1
              len -= 1
            end
          end
          out.puts ")"
          render_nested_definitions element, out
        end
        out.puts "}"
      end

      def render_typedef(typedef, out)
        name = name_string typedef.name
        out.puts <<-EOS.strip_heredoc
          case class #{name} (self: #{decl_string typedef.declaration}) {
            def encode(stream: XdrDataOutputStream): Unit = {
        EOS
        out.indent(2) do
              encode_decl typedef.declaration, "self", false, out
        end
        out.puts <<-EOS.strip_heredoc
            }
          }
          object #{name} {
            def decode(stream: XdrDataInputStream): #{name} = #{name}(#{decode_decl typedef.declaration})
          }
        EOS
      end

      def render_union(union, out)
        name = name_string union.name
        def render_arms(union)
          union.arms.each do |arm|
            if arm.is_a? AST::Definitions::UnionDefaultArm
              yield arm.declaration, "d", "Default", true
            else
              arm.cases.each do |kase|
                dtype = type_string union.discriminant.type
                ktype =
                  if kase.value.is_a?(AST::Identifier)
                    "#{dtype}.#{name_string kase.value.name}"
                  elsif union.discriminant.type.is_a?(AST::Typespecs::Simple)
                    "#{dtype}(#{kase.value.value})"
                  else
                    "#{kase.value.value}"
                  end
                rtype = kase.value.is_a?(AST::Identifier) ? "#{name_string kase.value.name}" : "R_#{kase.value.value}"
                yield arm.declaration, ktype, rtype, false
              end
            end
          end
        end

        out.puts <<-EOS.strip_heredoc
          sealed trait #{name} {
            def encode(stream: XdrDataOutputStream): Unit
          }

          object #{name} {
            def decode(stream: XdrDataInputStream): #{name} = #{decode_type union.discriminant.type} match {
        EOS
        out.indent do
          out.indent do
            the_default = "case d => throw new IllegalArgumentException(s\"#{type_string union.discriminant.type} value $d is invalid\")"
            render_arms(union) do |decl, ktype, rtype, is_default|
              decode = "#{decode_decl decl}"
              if is_default
                the_default = "case #{ktype} => #{rtype}(d" + (is_void?(decl) ? "" : ", #{decode}") + ")"
              else
                out.puts "case #{ktype} => #{rtype}#{is_void?(decl) ? "" : "(" + decode + ")" }"
              end
            end
            out.puts the_default
          end
          out.puts "}"
          out.puts ""
          render_arms(union) do |decl, ktype, rtype, is_default|
            type = "class"
            args = is_default ? "(d: #{type_string union.discriminant.type}" : ""
            unless is_void? decl
              args += (args.empty? ? "(" : ", ") + "x: #{decl_string decl})"
            else
              args += args.empty? ? "" : ")"
            end
            if !is_default && is_void?(decl)
              type = "object"
              args = ""
            end
            out.puts "case #{type} #{rtype}#{args} extends #{name} {"
            out.indent do
              out.puts "def encode(stream: XdrDataOutputStream): Unit = {"
              out.indent do
                encode_decl union.discriminant, ktype, false, out
                unless is_void? decl
                  encode_decl decl, "x", false, out
                end
              end
              out.puts "}"
            end
            out.puts "}"
          end

          render_nested_definitions union, out
        end
        out.puts "}"
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Automatically generated by xdrgen
          // DO NOT EDIT or your changes may be overwritten

          package #{@namespace || "main"}

          import stellar.sdk._

        EOS
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

      def encode_member(member, out)
        encode_decl member.declaration, member.name, member.type.sub_type == :optional, out
      end

      def encode_decl(decl, name, isOption, out)
        case decl
          when AST::Declarations::Void
            return
        end

        if isOption
          out.puts "#{sanitize name} match {"
          out.indent do
            out.puts "case Some(x) => "
            out.indent do
              out.puts "stream.writeInt(1)"
              encode_decl_inner(decl, "x", out)
            end
            out.puts "case None => stream.writeInt(0)"
          end
          out.puts "}"
        else
          encode_decl_inner(decl, sanitize(name), out)
        end
      end

      def encode_decl_inner(decl, name, out)
        case decl
        when AST::Declarations::Opaque ;
          unless decl.fixed?
            out.puts "stream.writeInt(#{name}.length)"
          end
          out.puts "stream.write(#{name}, 0, #{name}.length)"
        when AST::Declarations::Array ;
          unless decl.fixed?
            out.puts "stream.writeInt(#{name}.length)"
          end
          out.puts "#{name}.foreach { #{encode_type decl.type, "_"} }"
        else
          out.puts "#{encode_type decl.type, "#{name}"}"
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
          raise "cannot render quadruple in scala"
        when AST::Typespecs::Bool ;
          "stream.writeInt(if (#{value}) 1 else 0)"
        when AST::Typespecs::String ;
          "stream.writeString(#{value})"
        when AST::Typespecs::Simple ;
          "#{value}.encode(stream)"
        when AST::Concerns::NestedDefinition ;
          "#{value}.encode(stream)"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decode_member(member, out, final)
        case member.declaration
        when AST::Declarations::Void ;
          return
        end
        str = decode_decl (member.declaration)
        if member.type.sub_type == :optional
          out.puts "if (stream.readInt == 0) None else Some(" + str + ")" + (final ? "" : ",")
        else
          out.puts str + (final ? "" : ",")
        end
      end

      def decode_decl(decl)
        case decl
        when AST::Declarations::Void ;
          return
        when AST::Declarations::Opaque ;
          size = decl.fixed? ? decl.size : "stream.readInt"
          return "stream.readBytes(#{size})"
        when AST::Declarations::Array ;
          size = decl.fixed? ? decl.size : "stream.readInt"
          return "(0 until #{size}).map(_ => #{decode_type decl.type}).toArray"
        else
          return decode_type decl.type
        end
      end

      def decode_type(type)
        case type
        when AST::Typespecs::Int ;
          "stream.readInt"
        when AST::Typespecs::UnsignedInt ;
          "stream.readInt"
        when AST::Typespecs::Hyper ;
          "stream.readLong"
        when AST::Typespecs::UnsignedHyper ;
          "stream.readLong"
        when AST::Typespecs::Float ;
          "stream.readFloat"
        when AST::Typespecs::Double ;
          "stream.readDouble"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in scala"
        when AST::Typespecs::Bool ;
          "stream.readInt == 1"
        when AST::Typespecs::String ;
          "stream.readString"
        when AST::Typespecs::Simple ;
          "#{name type.resolved_type}.decode(stream)"
        when AST::Concerns::NestedDefinition ;
          "#{name type}.decode(stream)"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decl_string(decl)
        case decl
        when AST::Declarations::Opaque ;
          "Array[Byte]"
        when AST::Declarations::String ;
          "String"
        when AST::Declarations::Array ;
          "Array[#{type_string decl.type}]"
        when AST::Declarations::Optional ;
          "Option[#{type_string(decl.type)}]"
        when AST::Declarations::Simple ;
          type_string(decl.type)
        when AST::Declarations::Void ;
            "Unit"
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Int ;
          "Int"
        when AST::Typespecs::UnsignedInt ;
          "Int"
        when AST::Typespecs::Hyper ;
          "Long"
        when AST::Typespecs::UnsignedHyper ;
          "Long"
        when AST::Typespecs::Float ;
          "Float"
        when AST::Typespecs::Double ;
          "Double"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in scala"
        when AST::Typespecs::Bool ;
          "Boolean"
        when AST::Typespecs::Opaque ;
          "Array.ofDim[Byte](#{type.size})"
        when AST::Typespecs::Simple ;
          name type.resolved_type
        when AST::Concerns::NestedDefinition ;
          name type
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def is_nested?(defn)
        defn.is_a?(AST::Concerns::NestedDefinition)
      end

      def is_void?(decl)
        decl.is_a?(AST::Declarations::Void)
      end

      def name(named)
        name_string named.name
      end

      def name_string(name)
        # ensure that first letters are capitalized, but leave ENUM_LIKE_THINGS alone
        name["_"] || !name[/[^A-Z]/] ? name : name.camelize
      end

      def sanitize(name)
        if name == "type"
          "`type`"
        else
            name
        end
      end
    end
  end
end
