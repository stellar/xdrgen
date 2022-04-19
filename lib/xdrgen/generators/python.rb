# Note:
# 1. If the .x file contains Python reserved words, I suggest you change them to non-reserved words.
# 2. You can generate the file with the following command
#   xdrgen -o OUTPUT_DIR INPUT -l python
# 3. The generated code is unformatted, I suggest you format it by the following command:
#   autoflake --in-place --ignore-init-module-imports --remove-all-unused-imports OUTPUT_DIR/*.py
#   isort OUTPUT_DIR/
#   black OUTPUT_DIR/

module Xdrgen
  module Generators
    class Python < Xdrgen::Generators::Base
      MAX_SIZE = (2 ** 32) - 1

      def generate
        @constants_out = @output.open("constants.py")
        @constants_out.puts <<-EOS.strip_heredoc
          # This is an automatically generated file.
          # DO NOT EDIT or your changes may be overwritten
        EOS

        @init_out = @output.open("__init__.py")
        @init_out.puts <<-EOS.strip_heredoc
          # Automatically generated on #{Time.now.iso8601}
          # DO NOT EDIT or your changes may be overwritten
          from .base import *
          from .constants import *
        EOS

        render_base_classes
        render_definitions(@top)
      end

      private

      def render_definitions(node)
        node.definitions.each { |n| render_definition n }
        node.namespaces.each { |n| render_definitions n }
      end

      def render_nested_definitions(defn)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each { |ndefn| render_definition ndefn }
      end

      def render_definition(defn)
        render_nested_definitions(defn)
        case defn
        when AST::Definitions::Struct;
          render_struct defn
        when AST::Definitions::Enum
          render_enum defn
        when AST::Definitions::Union;
          render_union defn
        when AST::Definitions::Typedef
          render_typedef defn
        when AST::Definitions::Const
          render_const defn
        end
      end

      def render_const(const)
        render_const_source_comment @constants_out, const
        @constants_out.puts "#{const.name}: int = #{const.value}"
      end

      def render_enum(enum)
        enum_name = enum.name
        enum_name_underscore = enum.name.underscore
        @init_out.puts "from .#{enum_name_underscore} import #{enum_name}"

        file_name = "#{enum_name_underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        out.puts "__all__ = ['#{enum_name}']"

        out.puts "class #{enum_name}(IntEnum):"
        out.indent(2) do
          render_source_comment out, enum
          enum.members.each do |member|
            out.puts "#{member.name} = #{member.value}"
          end

          out.puts <<~HEREDOC
            def pack(self, packer: Packer) -> None:
                packer.pack_int(self.value)
  
            @classmethod
            def unpack(cls, unpacker: Unpacker) -> "#{enum_name}":
                value = unpacker.unpack_int()
                return cls(value)
          HEREDOC

          render_xdr_utils out, enum_name
          out.close
        end
      end

      def render_typedef(typedef)
        typedef_name = typedef.name.camelize
        typedef_name_underscore = typedef.name.underscore

        @init_out.puts "from .#{typedef_name_underscore} import #{typedef_name}"

        file_name = "#{typedef_name_underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        render_import out, typedef, typedef_name

        out.puts "__all__ = ['#{typedef_name}']"

        out.puts "class #{typedef_name}:"
        out.indent(2) do
          render_source_comment(out, typedef)
          out.puts "def __init__(self, #{typedef_name_underscore}: #{type_hint_string typedef, typedef_name}) -> None:"
          out.indent(2) do
            render_array_length_checker typedef, out
            out.puts "self.#{typedef_name_underscore} = #{typedef_name_underscore}"
          end

          out.puts "def pack(self, packer: Packer) -> None:"
          out.indent(2) do
            encode_member typedef, out
          end

          out.puts "@classmethod"
          out.puts "def unpack(cls, unpacker: Unpacker) -> \"#{typedef_name}\":"
          out.indent(2) do
            decode_member typedef, out
            out.puts "return cls(#{typedef_name_underscore})"
          end
          render_xdr_utils(out, typedef_name)
          out.puts <<~HEREDOC
            def __eq__(self, other: object):
                if not isinstance(other, self.__class__):
                    return NotImplemented
                return self.#{typedef_name_underscore} == other.#{typedef_name_underscore}

            def __str__(self):
                return f"<#{typedef_name} [#{typedef_name_underscore}={self.#{typedef_name_underscore}}]>"
          HEREDOC
        end
        out.close
      end

      def render_import(out, member, container_name)
        member_type = type_string member.type
        unless is_base_type member.type or container_name == member_type
          out.puts "from .#{member_type.underscore} import #{member_type}"
        end
      end

      def render_union(union)
        union_name = name union
        union_name_underscore = union_name.underscore
        @init_out.puts "from .#{union_name_underscore} import #{union_name}"

        file_name = "#{union_name_underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        render_import out, union.discriminant, union_name

        union.arms.each do |arm|
          next if arm.void?
          # This may cause duplicate imports, we can remove it with autoflake
          render_import out, arm.declaration, union_name
        end

        out.puts "__all__ = ['#{union_name}']"

        out.puts "class #{union_name}:"
        out.indent(2) do
          render_source_comment(out, union)
          union_discriminant_name_underscore = union.discriminant.name.underscore
          out.puts <<~HEREDOC
            def __init__(
                self,
                #{union_discriminant_name_underscore}: #{type_hint_string union.discriminant, union_name},
          HEREDOC

          out.indent(2) do
            union.arms.each do |arm|
              next if arm.void?
              out.puts "#{arm.name.underscore}: #{type_hint_string arm.declaration, union_name} = None,"
            end
          end

          out.puts ") -> None:"
          out.indent(2) do
            union.arms.each do |arm|
              next if arm.void?
              render_array_length_checker arm, out
            end

            out.puts "self.#{union_discriminant_name_underscore} = #{union_discriminant_name_underscore}"
            union.arms.each do |arm|
              next if arm.void?
              arm_name_underscore = arm.name.underscore
              out.puts "self.#{arm_name_underscore} = #{arm_name_underscore}"
            end
          end
          out.puts "def pack(self, packer: Packer) -> None:"
          out.indent(2) do
            out.puts "#{encode_type union.discriminant, union_discriminant_name_underscore}"
            union.normal_arms.each do |arm|
              arm.cases.each do |c|
                if c.value.is_a?(AST::Identifier)
                  out.puts "if self.#{union_discriminant_name_underscore} == #{type_string union.discriminant.type}.#{c.value.name}:"
                else
                  out.puts "if self.#{union_discriminant_name_underscore} == #{c.value.value}:"
                end
                out.indent(2) do
                  unless arm.void?
                    encode_member arm, out, true
                  end
                  out.puts "return"
                end
              end
            end
            if union.default_arm.present? and not union.default_arm.void?
              encode_member union.default_arm, out, true
            end
          end

          out.puts "@classmethod"
          out.puts "def unpack(cls, unpacker: Unpacker) -> \"#{union_name}\":"
          out.indent(2) do
            out.puts "#{union_discriminant_name_underscore} = #{decode_type union.discriminant}"
            union.normal_arms.each do |arm|
              arm.cases.each do |c|
                if c.value.is_a?(AST::Identifier)
                  out.puts "if #{union_discriminant_name_underscore} == #{type_string union.discriminant.type}.#{c.value.name}:"
                else
                  out.puts "if #{union_discriminant_name_underscore} == #{c.value.value}:"
                end
                out.indent(2) do
                  if arm.void?
                    out.puts "return cls(#{union_discriminant_name_underscore}=#{union_discriminant_name_underscore})"
                  else
                    decode_member arm, out
                    arm_name_underscore = arm.name.underscore
                    out.puts "return cls(#{union_discriminant_name_underscore}=#{union_discriminant_name_underscore}, #{arm_name_underscore}=#{arm_name_underscore})"
                  end
                end
              end
            end

            if union.default_arm.present? and not union.default_arm.void?
              decode_member union.default_arm, out
              arm_name_underscore = union.default_arm.name.underscore
              out.puts "return cls(#{union_discriminant_name_underscore}=#{union_discriminant_name_underscore}, #{arm_name_underscore}=#{arm_name_underscore})"
            else
              out.puts "return cls(#{union_discriminant_name_underscore}=#{union_discriminant_name_underscore})"
            end
          end

          render_xdr_utils(out, union_name)
          attribute_names = []
          attribute_names.push(union_discriminant_name_underscore)
          union.arms.each do |arm|
            next if arm.void?
            attribute_names.push(arm.name.underscore)
          end
          out.puts <<~HEREDOC
            def __eq__(self, other: object):
                if not isinstance(other, self.__class__):
                    return NotImplemented
                return #{attribute_names.map { |m| 'self.' + m + '== other.' + m }.join(" and ")}
          HEREDOC

          out.puts "def __str__(self):"
          out.indent(2) do
            out.puts "out = []"
            out.puts "out.append(f'#{union_discriminant_name_underscore}={self.#{union_discriminant_name_underscore}}')"
            union.arms.each do |arm|
              next if arm.void?
              arm_name_underscore = arm.name.underscore
              out.puts "out.append(f'#{arm_name_underscore}={self.#{arm_name_underscore}}') if self.#{arm_name_underscore} is not None else None"
            end
            out.puts "return f\"<#{union_name} {[', '.join(out)]}>\""
          end
        end
        out.close
      end

      def render_struct(struct)
        struct_name = name struct
        struct_name_underscore = struct_name.underscore
        @init_out.puts "from .#{struct_name_underscore} import #{struct_name}"

        file_name = "#{struct_name_underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        struct.members.each do |member|
          # This may cause duplicate imports, we can remove it through autoflake
          render_import out, member.declaration, struct_name
        end

        out.puts "__all__ = ['#{struct_name}']"

        out.puts "class #{struct_name}:"
        out.indent(2) do
          render_source_comment(out, struct)
          out.puts <<~HEREDOC
            def __init__(
                self,
          HEREDOC

          out.indent(2) do
            struct.members.each do |member|
              out.puts "#{member.name.underscore}: #{type_hint_string member.declaration, struct_name},"
            end
          end
          out.puts ") -> None:"

          out.indent(2) do
            struct.members.each do |member|
              render_array_length_checker member, out
            end
            struct.members.each do |member|
              member_name_underscore = member.name.underscore
              out.puts "self.#{member_name_underscore} = #{member_name_underscore}"
            end
          end
          out.puts "def pack(self, packer: Packer) -> None:"
          out.indent(2) do
            struct.members.each do |member|
              encode_member member, out
            end
          end

          out.puts "@classmethod"
          out.puts "def unpack(cls, unpacker: Unpacker) -> \"#{struct_name}\":"
          out.indent(2) do
            struct.members.each do |member|
              decode_member member, out
            end
            out.puts "return cls("
            out.indent(2) do
              struct.members.each do |member|
                member_name_underscore = member.name.underscore
                out.puts "#{member_name_underscore}=#{member_name_underscore},"
              end
            end
            out.puts ")"
          end

          render_xdr_utils(out, struct_name)

          attribute_names = []
          struct.members.each do |member|
            attribute_names.push(member.name.underscore)
          end
          out.puts <<~HEREDOC
            def __eq__(self, other: object):
                if not isinstance(other, self.__class__):
                    return NotImplemented
                return #{attribute_names.map { |m| 'self.' + m + '== other.' + m }.join(" and ")}
          HEREDOC

          out.puts "def __str__(self):"
          out.indent(2) do
            out.puts "out = ["
            out.indent(2) do
              attribute_names.each do |name|
                name = name
                out.puts "f'#{name}={self.#{name}}',"
              end
            end
            out.puts "]"
            out.puts "return f\"<#{struct_name} {[', '.join(out)]}>\""
          end

        end
        out.close
      end

      def encode_member(member, out, is_union_member = false)
        case member.declaration
        when AST::Declarations::Void
          out.puts "return"
        end
        member_name_underscore = member.name.underscore
        if member.type.sub_type == :optional
          out.puts <<~HEREDOC
            if self.#{member_name_underscore} is None:
                packer.pack_uint(0)
            else:
                packer.pack_uint(1)
          HEREDOC
        end

        out.indent(member.type.sub_type == :optional ? 2 : 0) do
          case member.declaration
          when AST::Declarations::Array
            if is_union_member # All members of union are actually optional
              out.puts <<~HEREDOC
                if self.#{member_name_underscore} is None:
                    raise ValueError("#{member_name_underscore} should not be None.")
              HEREDOC
            end
            unless member.declaration.fixed?
              out.puts "packer.pack_uint(len(self.#{member_name_underscore}))"
            end
            out.puts <<~HEREDOC
              for #{member_name_underscore}_item in self.#{member_name_underscore}:
                  #{member_name_underscore}_item.pack(packer)
            HEREDOC
          else
            if member.type.sub_type == :optional or is_union_member
              out.puts <<~HEREDOC
                if self.#{member_name_underscore} is None:
                    raise ValueError("#{member_name_underscore} should not be None.")
              HEREDOC
            end
            out.puts "#{encode_type member.declaration, member_name_underscore}"
          end
        end
      end

      def decode_member(member, out)
        case member.declaration
        when AST::Declarations::Void;
          out.puts "return"
        end
        member_name_underscore = member.name.underscore
        decoded_member_declaration = decode_type member.declaration

        case member.declaration
        when AST::Declarations::Array
          if member.declaration.fixed?
            _, size = member.declaration.type.array_size
            out.puts "length = #{size}"
          else
            out.puts "length = unpacker.unpack_uint()"
          end
          out.puts <<-EOS.strip_heredoc
            #{member_name_underscore} = []
            for _ in range(length):
                #{member_name_underscore}.append(#{decoded_member_declaration})
          EOS
        else
          if member.type.sub_type == :optional
            out.puts "#{member_name_underscore} = #{decoded_member_declaration} if unpacker.unpack_uint() else None"
          else
            out.puts "#{member_name_underscore} = #{decoded_member_declaration}"
          end
        end
      end

      def render_common_import(out)
        out.puts <<-EOS.strip_heredoc
          # This is an automatically generated file.
          # DO NOT EDIT or your changes may be overwritten
          import base64
          from enum import IntEnum
          from typing import List, Optional
          from xdrlib import Packer, Unpacker
          from .base import Integer, UnsignedInteger, Float, Double, Hyper, UnsignedHyper, Boolean, String, Opaque
          from .constants import *
        EOS
        out.break
      end

      def render_array_length_checker(member, out)
        case member.declaration
        when AST::Declarations::Array
          _, size = member.declaration.type.array_size
          member_name_underscore = member.name.underscore
          if member.declaration.fixed?
            out.puts <<~HEREDOC
              if #{member_name_underscore} and len(#{member_name_underscore}) != #{size}:
                  raise ValueError(f\"The length of `#{member_name_underscore}` should be #{size}, but got {len(#{member_name_underscore})}.\")
            HEREDOC
          else
            out.puts <<~HEREDOC
              if #{member_name_underscore} and len(#{member_name_underscore}) > #{size || MAX_SIZE}:
                  raise ValueError(f\"The maximum length of `#{member_name_underscore}` should be #{size || MAX_SIZE}, but got {len(#{member_name_underscore})}.\")
            HEREDOC
          end
        end
      end

      def render_xdr_utils(out, name)
        out.puts <<~HEREDOC
          def to_xdr_bytes(self) -> bytes:
              packer = Packer()
              self.pack(packer)
              return packer.get_buffer()

          @classmethod
          def from_xdr_bytes(cls, xdr: bytes) -> "#{name}":
              unpacker = Unpacker(xdr)
              return cls.unpack(unpacker)

          def to_xdr(self) -> str:
              xdr_bytes = self.to_xdr_bytes()
              return base64.b64encode(xdr_bytes).decode()

          @classmethod
          def from_xdr(cls, xdr: str) -> "#{name}":
              xdr_bytes = base64.b64decode(xdr.encode())
              return cls.from_xdr_bytes(xdr_bytes)
        HEREDOC
      end

      def render_base_classes
        file_name = "base.py"
        out = @output.open(file_name)
        base_py_content = IO.read(__dir__ + "/python/base.py")
        out.puts base_py_content
        out.close
      end

      def encode_type(decl, value)
        case decl.type
        when AST::Typespecs::Int;
          "Integer(self.#{value}).pack(packer)"
        when AST::Typespecs::UnsignedInt;
          "UnsignedInteger(self.#{value}).pack(packer)"
        when AST::Typespecs::Hyper;
          "Hyper(self.#{value}).pack(packer)"
        when AST::Typespecs::UnsignedHyper;
          "UnsignedHyper(self.#{value}).pack(packer)"
        when AST::Typespecs::Float;
          "Float(self.#{value}).pack(packer)"
        when AST::Typespecs::Double;
          "Double(self.#{value}).pack(packer)"
        when AST::Typespecs::Quadruple;
          raise "cannot render quadruple in Python"
        when AST::Typespecs::Bool;
          "Boolean(self.#{value}).pack(packer)"
        when AST::Typespecs::Opaque;
          "Opaque(self.#{value}, #{decl.size || MAX_SIZE}, #{decl.fixed? ? "True" : "False"}).pack(packer)"
        when AST::Typespecs::String;
          "String(self.#{value}, #{decl.size || MAX_SIZE}).pack(packer)"
        else
          "self.#{value}.pack(packer)"
        end
      end

      def decode_type(decl)
        case decl.type
        when AST::Typespecs::Int
          "Integer.unpack(unpacker)"
        when AST::Typespecs::UnsignedInt
          "UnsignedInteger.unpack(unpacker)"
        when AST::Typespecs::Hyper
          "Hyper.unpack(unpacker)"
        when AST::Typespecs::UnsignedHyper
          "UnsignedHyper.unpack(unpacker)"
        when AST::Typespecs::Float
          "Float.unpack(unpacker)"
        when AST::Typespecs::Double
          "Double.unpack(unpacker)"
        when AST::Typespecs::Quadruple
          raise "cannot render quadruple in Python"
        when AST::Typespecs::Bool
          "Integer.unpack(unpacker)"
        when AST::Typespecs::Opaque
          "Opaque.unpack(unpacker, #{decl.size || MAX_SIZE}, #{decl.fixed? ? "True" : "False"})"
        when AST::Typespecs::String
          "String.unpack(unpacker)"
        when AST::Typespecs::Simple
          "#{name decl.type.resolved_type}.unpack(unpacker)"
        when AST::Concerns::NestedDefinition
          "#{name decl.type}.unpack(unpacker)"
        else
          raise "Unknown typespec: #{decl.type.class.name}"
        end
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts <<-EOS.strip_heredoc
          """
          XDR Source Code::

        EOS
        out.indent(2) do
          out.puts defn.text_value
        end

        out.puts '"""'
      end

      def render_const_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)
        out.puts "#: #{defn.text_value}"
      end

      def type_hint_string(decl, container_name)
        type_hint = type_string decl.type
        if type_hint == container_name
          type_hint = "\"#{type_hint}\""
        end

        case decl.type.sub_type
        when :optional
          "Optional[#{type_hint}]"
        when :var_array, :array
          "List[#{type_hint}]"
        else
          type_hint
        end
      end

      def is_base_type(type)
        case type
        when AST::Typespecs::Bool,
          AST::Typespecs::Double,
          AST::Typespecs::Float,
          AST::Typespecs::Hyper,
          AST::Typespecs::Int,
          AST::Typespecs::Opaque,
          AST::Typespecs::String,
          AST::Typespecs::UnsignedHyper,
          AST::Typespecs::UnsignedInt
          true
        else
          false
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Bool
          "bool"
        when AST::Typespecs::Double
          "float"
        when AST::Typespecs::Float
          "float"
        when AST::Typespecs::Hyper
          "int"
        when AST::Typespecs::Int
          "int"
        when AST::Typespecs::Opaque
          "bytes"
        when AST::Typespecs::Quadruple
          raise "no quadruple support for Python"
        when AST::Typespecs::String
          "bytes"
        when AST::Typespecs::UnsignedHyper
          "int"
        when AST::Typespecs::UnsignedInt
          "int"
        when AST::Typespecs::Simple
          name type
        when AST::Definitions::Base
          name type
        when AST::Concerns::NestedDefinition
          name type
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end
      end

      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)
        result = named.name.camelize
        "#{parent}#{result}"
      end
    end
  end
end