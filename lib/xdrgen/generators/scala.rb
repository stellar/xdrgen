module Xdrgen
  module Generators

    class Scala < Xdrgen::Generators::Base

      class Enum
        attr_accessor :name, :members, :element

        def initialize(name, members, element)
          @name = name
          @members = members
          @element = element
        end
      end

      class Constant
        attr_accessor :name, :value, :element

        def initialize(name, value, element)
          @name = name
          @value = value
          @element = element
        end
      end

      class TypeDef
        attr_accessor :name, :declaration, :is_optional, :element

        def initialize(name, declaration, element, is_optional = false)
          @name = name
          @declaration = declaration
          @is_optional = is_optional
          @element = element
        end
      end

      def generate
        render_lib
        generate_for @top
      end

      def generate_for(node)
        enums = parse_enums node
        constants = parse_constants node
        typedefs = parse_typedefs node
        unions = parse_unions node
        structs = parse_structs node

        write_package_class constants
        enums.each(&method(:write_enum_file))
        typedefs.each(&method(:write_typedef_file))
        unions.each(&method(:write_union_file))
        structs.each(&method(:write_struct_file))

        node.namespaces.each(&method(:generate_for))
      end

      # def render_definitions(node)
      #   node.namespaces.each {|n| render_definitions n}
      #   node.definitions.each(&method(:render_definition))
      # end

      # def render_definition(defn)
      #   case defn
      #   when AST::Definitions::Struct;
      #     render_file defn do |out|
      #       render_struct defn, out
      #     end
      #   when AST::Definitions::Enum;
      #     render_file defn do |out|
      #       render_enum defn, out
      #     end
      #   when AST::Definitions::Union;
      #     render_file defn do |out|
      #       render_union defn, out
      #     end
      #   when AST::Definitions::Typedef;
      #     render_file defn do |out|
      #       render_typedef defn, out
      #     end
      #   end
      # end

      def enum_members(e)
        hash = e.members.reduce({}) do |hash, member|
          hash.store(member.name, member.value)
          hash
        end
      end

      def parse_enums(ns)
        ns.definitions.select {|d| d.is_a? AST::Definitions::Enum}.map do |e|
          Enum.new(name(e), enum_members(e), e)
        end
      end

      def parse_constants(ns)
        ns.definitions.select {|d| d.is_a? AST::Definitions::Const}.map do |c|
          Constant.new(c.name, c.value, c)
        end
      end

      def parse_typedefs(ns)
        ns.definitions.select {|d| d.is_a? AST::Definitions::Typedef}.map do |td|
          TypeDef.new(td.name.camelize, td.declaration, td, td.type.sub_type == :optional)
        end
      end

      def parse_unions(ns)
        ns.definitions.select {|d| d.is_a? AST::Definitions::Union}
      end

      def parse_structs(ns)
        ns.definitions.select {|d| d.is_a? AST::Definitions::Struct}
      end

      def write_enum_file(e)
        write_class_file e.name do |out|
          render_enum out, e.element, e.name, e.members
        end
      end

      def write_typedef_file(td)
        write_class_file td.name do |out|
          render_typedef out, td
        end
      end

      def write_union_file(u)
        write_class_file u.name do |out|
          render_union out, u
        end
      end

      def write_struct_file(s)
        write_class_file s.name do |out|
          render_struct out, s
        end
      end

      def write_class_file(name)
        path = "#{@namespace.downcase}/#{name.camelize}.scala"
        out = @output.open(path)
        render_top_matter out
        render_package out
        yield out
      end

      def write_package_class(constants)
        return if constants.empty?
        path = "#{@namespace.downcase}/#{@namespace.downcase}.scala"
        out = @output.open(path)
        render_top_matter out
        out.puts "package object #{@namespace.downcase} {"
          constants.each do |c|
            out.indent(1) do
              out.puts <<~EOS.strip_heredoc

              /*
                #{c.element.text_value.split("\n").join("\n    ")}
               */
              val #{c.name} = #{c.value}
              EOS
            end
          end
        out.puts "}"
      end

      def render_enum(out, enum, name, members)
        render_source_comment out, enum
        out.puts <<~EOS.strip_heredoc
        sealed abstract class #{name}(val i: Int) {
          def encode(stream: XdrDataOutputStream) = stream.writeInt(i)
        }

        object #{name} {
          def decode(stream: XdrDataInputStream): #{name} = stream.readInt() match {
            #{members.map {|k, v| "case #{v} => #{k}"}.join("\n    ")}
            case i => throw new IllegalArgumentException(s"#{name} value $i is invalid")
          }

          #{members.map {|k, v| "case object #{k} extends #{name}(#{v})"}.join("\n  ")}
        }
        EOS
      end

      def render_typedef(out, td)
        render_source_comment out, td.element

        out.puts <<-EOS.strip_heredoc
        case class #{td.name}(self: #{decl_string td.declaration}) {
          def encode(stream: XdrDataOutputStream): Unit = {
        EOS
        out.indent(2) do
          encode_decl td.declaration, "self", td.is_optional, out
        end
        out.puts <<-EOS.strip_heredoc
          }
        }

        EOS
        decode_str = decode_decl td.declaration
        decode_statement = td.is_optional ? "Option(#{decode_str})" : decode_str
        out.puts <<-EOS.strip_heredoc
          object #{td.name} {
            def decode(stream: XdrDataInputStream): #{td.name} = #{td.name}(#{decode_statement})
          }
        EOS
      end

      def decode_discriminant(disc)
        case disc.type_s
        when Xdrgen::AST::Identifier;
          "#{disc.type.name}.decode(stream)"
        else
          "stream.readInt()"
        end
      end

      # def as_arguments(decl)
      #   if is_void?(decl)
      #     ""
      #   else
      #     decl_string(decl)
      #   end
      # end
      #

      def decode_member_string(member, final)
        case member.declaration
        when AST::Declarations::Void;
          return
        end
        str = decode_decl(member.declaration)
        if member.type.sub_type == :optional
          "if (stream.readInt == 0) None else Some(" + str + ")" + (final ? "" : ",")
        else
          str + (final ? "" : ",")
        end
      end

      def encode_member_string(member)
        encode_decl_string(member.declaration, member.declaration.name, member.type.sub_type == :optional)
      end


      def match_arm(arm, union)
        def constructor_params(arm)
          if is_void?(arm.declaration)
            ""
          else # simple
            case arm.declaration.type_s
            when Xdrgen::AST::Definitions::NestedStruct;
              member_count = arm.declaration.type_s.members.size
              decoded_args = arm.declaration.type_s.members.map.with_index(1) {|m,i|
                decode_member_string(m, i == member_count)
              }.join(" ")
              "(#{decoded_args})"
            else
              "(#{decode_decl arm.declaration})"
            end
          end
        end

        def match_case(kase, arm, union)
          union_name = "#{name_string union.name}"

          case kase.value
          when Xdrgen::AST::Identifier;
            case_match = "#{union.discriminant.type.name}.#{kase.value.name}"
            "case #{case_match} => #{union_name}#{kase.value.name.downcase.camelize}#{constructor_params(arm)}"
          else
            "case #{kase.value.value} => #{union_name}#{kase.value.value}#{constructor_params(arm)}"
          end
        end

        case arm
        when Xdrgen::AST::Definitions::UnionDefaultArm;
          # todo - here how to get the constructor params? Perhaps make a fake case?
          # todo also - need to define the class
          "case _ => #{name_string union.name}Default#{constructor_params(arm)}"
        else
          arm.cases.map {|c| match_case(c, arm, union)}.join("\n")
        end
      end

      def class_arm(arm, union)
        def match_case(kase, arm, union)
          union_name = "#{name_string union.name}"
          class_or_object = is_void?(arm.declaration) ? "object" : "class"
          constructor_params =
              if is_void?(arm.declaration)
                ""
              else # simple
                case arm.declaration.type_s
                when Xdrgen::AST::Definitions::NestedStruct;
                  member_count = arm.declaration.type_s.members.size
                  decoded_args = arm.declaration.type_s.members.map.with_index(1) {|m,i|
                    "#{m.name}: #{decl_string m.declaration}#{(i==member_count) ? "" : ","}"
                  }.join(" ")
                  "(#{decoded_args})"
                else
                  "(#{arm.declaration.name}: #{decl_string arm.declaration})"
                end
              end

          member_encode_statements =
              if is_void?(arm.declaration)
                ""
              else # simple
                case arm.declaration.type_s
                when Xdrgen::AST::Definitions::NestedStruct;
                  "\n    " + arm.declaration.type_s.members.map(&method(:encode_member_string)).join("\n    ")
                else
                  "\n    #{encode_decl_string(arm.declaration, arm.declaration.name, arm.declaration.type.sub_type == :optional)}"
                end
              end

          case kase.value
          when Xdrgen::AST::Identifier;
            <<~EOS.strip_heredoc
            case #{class_or_object} #{union_name}#{kase.value.name.downcase.camelize}#{constructor_params} extends #{union_name} {
              def encode(stream: XdrDataOutputStream): Unit = {
                #{union.discriminant.type.name}.#{kase.value.name}.encode(stream)#{member_encode_statements}                
              }
            }
            EOS
          else
            <<~EOS.strip_heredoc
            case #{class_or_object} #{union_name}#{kase.value.value}#{constructor_params} extends #{union_name} {
              def encode(stream: XdrDataOutputStream): Unit = {
                stream.writeInt(#{kase.value.value})#{member_encode_statements}
              }
            }
            EOS
          end
        end

        case arm
        when Xdrgen::AST::Definitions::UnionDefaultArm;
          "sdf"
        else
          arm.cases.map {|c| match_case(c, arm, union)}.join("\n")
        end
      end

      def render_union(out, union)
        union_name = name_string union.name

        render_source_comment out, union

        out.puts <<-EOS.strip_heredoc
          object #{union_name} {
            def decode(stream: XdrDataInputStream): #{union_name} = #{decode_discriminant union.discriminant} match {
              #{union.arms.map {|a| match_arm(a, union)}.join("\n              ")}
            }
          }

        EOS

        out.puts <<-EOS.strip_heredoc
          sealed trait #{union_name} {
            def encode(stream: XdrDataOutputStream): Unit
          }
        EOS

        union.arms.map{|arm| class_arm(arm, union)}.each {|s| out.puts(s) }
      end

      def render_union_start_again(out, union)
        render_source_comment out, union
        name = name_string union.name

        def render_arms(union, name)
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
                rtype =
                    if kase.value.is_a?(AST::Identifier)
                      if is_void?(arm.declaration)
                        "#{name}#{name_string kase.value.name.downcase}"
                      elsif arm.declaration.type.sub_type == :simple
                        "#{name}#{arm.declaration.type.name.camelize}"
                      elsif arm.declaration.type.sub_type == :optional
                        "#{name}#{arm.declaration.type.name.camelize}Opt"
                      else
                        "#{name}#{arm.declaration.type.name.camelize}Array"
                      end
                    else
                      "#{name}#{kase.value.value}"
                    end
                yield arm.declaration, dtype, ktype, rtype
              end
            end
          end
        end

        out.puts <<-EOS.strip_heredoc
          sealed trait #{name} {
            def encode(stream: XdrDataOutputStream): Unit
          }
        EOS

        render_arms(union, name) do |decl, dtype, ktype, rtype|
          out.puts decl_wrapper(rtype, dtype, name, decl)
        end

        out.puts <<-EOS.strip_heredoc
        
        object #{name} {
          def decode(stream: XdrDataInputStream): #{name} = #{decode_type union.discriminant.type} match {
        EOS
        out.indent(2) do
          render_arms(union, name) do |decl, dtype, ktype, rtype|
            decode = "#{decode_decl decl}"
            out.puts "case #{ktype} => #{rtype}#{is_void?(decl) ? "" : "(#{decode})"}"
          end
          out.puts "case d => throw new IllegalArgumentException(s\"#{type_string union.discriminant.type} value $d is invalid\")"
        end
        out.puts <<-EOS.strip_heredoc
          }
        }
        EOS
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Automatically generated by xdrgen
          // DO NOT EDIT or your changes may be overwritten

        EOS
      end

      def render_package(out)
        out.puts <<-EOS.strip_heredoc
        package #{@namespace.downcase || "main"}

        EOS
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)
        out.puts "/*"
        out.puts "    #{defn.text_value.split("\n").join("\n    ")}"
        out.puts "*/"
      end

      def render_lib
        template = IO.read(__dir__ + "/scala/XdrDataInputStream.erb")
        result = ERB.new(template).result binding
        @output.write "#{@namespace.downcase}/XdrDataInputStream.scala", result

        template = IO.read(__dir__ + "/scala/XdrDataOutputStream.erb")
        result = ERB.new(template).result binding
        @output.write "#{@namespace.downcase}/XdrDataOutputStream.scala", result
      end

      def decl_wrapper(name, discriminator_name, super_name, decl)
        case decl
        when AST::Declarations::Opaque;
          <<-EOS.strip_heredoc
          case class #{name}(bs: Array[Byte]) extends #{super_name} {
            def encode(stream: XdrDataOutputStream) = {
              stream.writeInt(bs.length)
              stream.write(bs, 0, bs.length)
            }
          }
          EOS
        when AST::Declarations::String;
          <<-EOS.strip_heredoc
          case class #{name}(s: String) extends #{super_name} {
            def encode(stream: XdrDataOutputStream) = stream.writeString(s)
          }
          EOS
        when AST::Declarations::Array;
          <<-EOS.strip_heredoc
          case class #{name}(xs: Array[#{type_string decl.type}]) extends #{super_name} {
            def encode(stream: XdrDataOutputStream) = {
              stream.writeInt(xs.length)
              xs.foreach(_.encode(stream))
            }
          }
          EOS
        when AST::Declarations::Optional;
          <<-EOS.strip_heredoc
          case class #{name}(m: Option[#{discriminator_name}]) extends #{super_name} {
            def encode(stream: XdrDataOutputStream) = m match {
              case None => stream.writeInt(0)
              case Some(x) => 
                stream.writeInt(1)
                x.encode(stream)
            }
          }
          EOS
        when AST::Declarations::Simple;
          <<-EOS.strip_heredoc
          case class #{name}(x: #{discriminator_name}) extends #{super_name} {
            def encode(stream: XdrDataOutputStream) = x.encode(stream)
          }
          EOS
        when AST::Declarations::Void;
          <<-EOS.strip_heredoc
          case object #{name} extends #{super_name} {
            def encode(stream: XdrDataOutputStream) = Unit
          }
          EOS
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      # ----


      # def render_constants(node, out)
      #   node.namespaces.each{|n| render_constants(n, out) }
      #   node.definitions.select{|c| c.is_a? AST::Definitions::Const}.each { |c| render_const out, c }
      # end
      #
      # def render_const(out, const)
      #   out.indent do
      #     out.puts "val #{const.name.downcase.camelize} = #{const.value.downcase.camelize}"
      #   end
      # end

      def render_file(element)
        path = "#{@namespace.downcase}/#{element.name.camelize}.scala"
        out = @output.open(path)
        render_top_matter out
        render_source_comment out, element

        yield out
      end

      def render_nested_definitions(defn, out)
        return unless defn.respond_to? :nested_definitions
        unless defn.nested_definitions.empty?
          out.puts ""
        end
        defn.nested_definitions.each {|ndefn|
          case ndefn
          when AST::Definitions::Struct;
            name = name ndefn
            render_struct out, ndefn
          when AST::Definitions::Enum;
            name = name ndefn
            render_enum out, ndefn, name, enum_members(ndefn)
          when AST::Definitions::Union;
            name = name ndefn
            render_union out, ndefn
          when AST::Definitions::Typedef;
            name = name ndefn
            render_typedef out, ndefn
          end
        }
      end

      def render_struct(out, struct, superclass = nil)
        render_source_comment out, struct
        name = name_string struct.name.camelize
        out.puts "case class #{name} ("
        out.indent do
          len = struct.members.length
          struct.members.each do |m|
            out.puts "#{sanitize m.name}: " + (is_nested?(m.type) ? "#{name}." : "") + "#{decl_string m.declaration}" + (len > 1 ? ", " : "")
            len -= 1
          end
        end
        out.puts ") #{superclass ? "extends #{superclass} " : ""}{"
        out.indent do
          out.puts "def encode(stream: XdrDataOutputStream): Unit = {"
          out.indent do
            out.puts "#{superclass}.encode(this, stream)" if superclass
            struct.members.each do |m|
              encode_member m, out
            end
          end
        end
        out.puts "  }"
        out.puts "}"
        out.puts ""
        out.puts "object #{name} {"
        out.puts "  def decode(stream: XdrDataInputStream): #{name} = #{name struct}("
        out.indent do
          out.indent do
            len = struct.members.length
            struct.members.each do |m|
              decode_member m, out, len == 1
              len -= 1
            end
          end
          out.puts ")"
          render_nested_definitions struct, out
        end
        out.puts "}"
        out.puts ""
      end

      def encode_member(member, out)
        encode_decl member.declaration, member.name, member.type.sub_type == :optional, out
      end

      def encode_decl_string(decl, name, is_option)

        def inner(decl, name)
          case decl
          when AST::Declarations::Opaque;
            <<~EOS.strip_heredoc
            #{"stream.writeInt(#{name}.length)" unless decl.fixed?}
            stream.write(#{name}, 0, #{name}.length)
            EOS

          when AST::Declarations::Array;
            <<~EOS.strip_heredoc
            #{"stream.writeInt(#{name}.length)" unless decl.fixed?}
            #{name}.foreach(#{encode_type decl.type, "_"})
            EOS

          else
            "#{encode_type decl.type, "#{name}"}"
          end
        end

        case decl
        when AST::Declarations::Void;
          ""
        else
          if is_option
            <<~EOS.strip_heredoc
            #{sanitize name} match {
              case Some(x) =>
                stream.writeInt(1)
                #{inner(decl, "x")}
              case None => 
                stream.writeInt(0)
            }
            EOS
          else
            inner(decl, sanitize(name))
          end
        end
      end

      def encode_decl(decl, name, is_option, out)
        case decl
        when AST::Declarations::Void
          return
        end

        if is_option
          out.puts "#{sanitize name} match {"
          out.indent do
            out.puts "case Some(x) => "
            out.indent do
              out.puts "stream.writeInt(1)"
              encode_decl_inner(decl, "x", out)
            end
            out.puts "case None =>"
            out.indent do
              out.puts "stream.writeInt(0)"
            end
          end
          out.puts "}"
        else
          encode_decl_inner(decl, sanitize(name), out)
        end
      end

      def encode_decl_inner(decl, name, out)
        case decl
        when AST::Declarations::Opaque;
          unless decl.fixed?
            out.puts "stream.writeInt(#{name}.length)"
          end
          out.puts "stream.write(#{name}, 0, #{name}.length)"
        when AST::Declarations::Array;
          unless decl.fixed?
            out.puts "stream.writeInt(#{name}.length)"
          end
          out.puts "#{name}.foreach(#{encode_type decl.type, "_"})"
        else
          out.puts "#{encode_type decl.type, "#{name}"}"
        end
      end

      def encode_type(type, value)
        case type
        when AST::Typespecs::Int;
          "stream.writeInt(#{value})"
        when AST::Typespecs::UnsignedInt;
          "stream.writeInt(#{value})"
        when AST::Typespecs::Hyper;
          "stream.writeLong(#{value})"
        when AST::Typespecs::UnsignedHyper;
          "stream.writeLong(#{value})"
        when AST::Typespecs::Float;
          "stream.writeFloat(#{value})"
        when AST::Typespecs::Double;
          "stream.writeDouble(#{value})"
        when AST::Typespecs::Quadruple;
          raise "cannot render quadruple in scala"
        when AST::Typespecs::Bool;
          "stream.writeInt(if (#{value}) 1 else 0)"
        when AST::Typespecs::String;
          "stream.writeString(#{value})"
        when AST::Typespecs::Simple;
          "#{value}.encode(stream)"
        when AST::Concerns::NestedDefinition;
          "#{value}.encode(stream)"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decode_member(member, out, final)
        case member.declaration
        when AST::Declarations::Void;
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
        when AST::Declarations::Void;
          return
        when AST::Declarations::Opaque;
          size = decl.fixed? ? decl.size : "stream.readInt"
          return "stream.readBytes(#{size})"
        when AST::Declarations::Array;
          size = decl.fixed? ? decl.size : "stream.readInt"
          return "(0 until #{size}).map(_ => #{decode_type decl.type}).toArray"
        else
          return decode_type decl.type
        end
      end

      def decode_type(type)
        case type
        when AST::Typespecs::Int;
          "stream.readInt"
        when AST::Typespecs::UnsignedInt;
          "stream.readInt"
        when AST::Typespecs::Hyper;
          "stream.readLong"
        when AST::Typespecs::UnsignedHyper;
          "stream.readLong"
        when AST::Typespecs::Float;
          "stream.readFloat"
        when AST::Typespecs::Double;
          "stream.readDouble"
        when AST::Typespecs::Quadruple;
          raise "cannot render quadruple in scala"
        when AST::Typespecs::Bool;
          "stream.readInt == 1"
        when AST::Typespecs::String;
          "stream.readString"
        when AST::Typespecs::Simple;
          "#{name type.resolved_type}.decode(stream)"
        when AST::Concerns::NestedDefinition;
          "#{name type}.decode(stream)"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def decl_string(decl)
        case decl
        when AST::Declarations::Opaque;
          "Array[Byte]"
        when AST::Declarations::String;
          "String"
        when AST::Declarations::Array;
          "Array[#{type_string decl.type}]"
        when AST::Declarations::Optional;
          "Option[#{type_string(decl.type)}]"
        when AST::Declarations::Simple;
          type_string(decl.type)
        when AST::Declarations::Void;
          "Unit"
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Int;
          "Int"
        when AST::Typespecs::UnsignedInt;
          "Int"
        when AST::Typespecs::Hyper;
          "Long"
        when AST::Typespecs::UnsignedHyper;
          "Long"
        when AST::Typespecs::Float;
          "Float"
        when AST::Typespecs::Double;
          "Double"
        when AST::Typespecs::Quadruple;
          raise "cannot render quadruple in scala"
        when AST::Typespecs::Bool;
          "Boolean"
        when AST::Typespecs::Opaque;
          "Array.ofDim[Byte](#{type.size})"
        when AST::Typespecs::Simple;
          name type.resolved_type
        when AST::Concerns::NestedDefinition;
          # todo - in some circumstances a nested defn should reference the enum type also
          # "#{type.parent_defn.name}#{name type}"
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