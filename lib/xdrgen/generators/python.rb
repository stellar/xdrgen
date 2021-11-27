module Xdrgen
  module Generators
    class Python < Xdrgen::Generators::Base
      MAX_SIZE = (2 ** 32) - 1

      def generate
        constants_file_name = "constants.py"
        # "A file cannot be opened twice", I am not very familiar with Ruby,
        # so I don’t want to modify the code in other files
        constants_out = @output.open(constants_file_name)
        constants_out.puts <<-EOS.strip_heredoc
          # This is an automatically generated file.
          # DO NOT EDIT or your changes may be overwritten
        EOS

        init_file_name = "__init__.py"
        init_out = @output.open(init_file_name)
        init_out.puts <<-EOS.strip_heredoc
          # Automatically generated on #{Time.now.iso8601}
          # DO NOT EDIT or your changes may be overwritten
          from .base import *
          from .constants import *
        EOS

        render_base_classes
        render_definitions(constants_out, init_out, @top)
      end

      def render_definitions(constants_out, init_out, node)
        node.definitions.each { |n| render_definition constants_out, init_out, n }
        node.namespaces.each { |n| render_definitions constants_out, init_out, n }
      end

      def render_nested_definitions(constants_out, init_out, defn)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each { |ndefn| render_definition constants_out, init_out, ndefn }
      end

      def render_definition(constants_out, init_out, defn)
        render_nested_definitions(constants_out, init_out, defn)
        case defn
        when AST::Definitions::Struct;
          render_struct init_out, defn
        when AST::Definitions::Enum
          render_enum init_out, defn
        when AST::Definitions::Union;
          render_union init_out, defn
        when AST::Definitions::Typedef
          render_typedef init_out, defn
        when AST::Definitions::Const
          render_const constants_out, defn
        end
      end

      def render_const(out, const)
        out.puts "#{const.name}: int = #{const.value}"
      end

      def render_enum(init_out, enum)
        enum_name = enum.name
        init_out.puts "from .#{enum_name.underscore} import #{enum_name}"

        file_name = "#{enum_name.underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        out.puts "__all__ = ['#{enum_name}']"

        out.puts "class #{enum_name}(IntEnum):"
        out.indent(2) do
          render_source_comment(out, enum)
          enum.members.each do |member|
            out.puts "#{member.name} = #{member.value}"
          end
        end
        out.indent(2) do
          out.puts <<~HEREDOC
            def pack(self, packer: Packer) -> None:
                packer.pack_int(self.value)
  
            @classmethod
            def unpack(cls, unpacker: Unpacker) -> "#{enum_name}":
                value = unpacker.unpack_int()
                return cls(value)
          HEREDOC

          render_xdr_utils(out, enum_name)
          out.close
        end
      end

      def render_typedef(init_out, typedef)
        init_out.puts "from .#{typedef.name.underscore} import #{typedef.name.camelize}"

        file_name = "#{typedef.name.underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        typedef_name = typedef.name.camelize

        render_import out, typedef, typedef_name

        out.puts "__all__ = ['#{typedef_name}']"

        out.puts "class #{typedef_name}:"
        out.indent(2) do
          render_source_comment(out, typedef)
          out.puts "def __init__(self, #{typedef_name.underscore}: #{type_hint_string typedef, typedef_name}) -> None:"
          out.indent(2) do
            render_array_length_checker typedef, out
            out.puts "self.#{typedef_name.underscore} = #{typedef_name.underscore}"
          end

          out.puts "def pack(self, packer: Packer) -> None:"
          out.indent(2) do
            encode_member typedef, out
          end

          out.puts "@classmethod"
          out.puts "def unpack(cls, unpacker: Unpacker) -> \"#{typedef_name}\":"
          out.indent(2) do
            decode_member typedef, out
            out.puts "return cls(#{typedef_name.underscore})"
          end
          render_xdr_utils(out, typedef_name)
          out.puts <<~HEREDOC
            def __eq__(self, other: object):
                if not isinstance(other, self.__class__):
                    return NotImplemented
                return self.#{typedef_name.underscore} == other.#{typedef_name.underscore}

            def __str__(self):
                return f"<#{typedef_name} [#{typedef.name.underscore}={self.#{typedef_name.underscore}}]>"
          HEREDOC
        end
        out.close
      end

      def render_import(out, member, container_name)
        unless is_base_type member.type or container_name == type_string(member.type)
          out.puts "from .#{type_string(member.type).underscore} import #{type_string member.type}"
        end
      end

      def render_union(init_out, union)
        union_name = name union
        init_out.puts "from .#{union_name.underscore} import #{union_name}"

        file_name = "#{union_name.underscore}.py"
        out = @output.open(file_name)
        render_common_import out

        render_import out, union.discriminant, union_name

        union.arms.each do |arm|
          next if arm.void?
          # This may cause duplicate imports, we can remove it through autoflake
          render_import out, arm.declaration, union_name
        end

        out.puts "__all__ = ['#{union_name}']"

        out.puts "class #{union_name}:"
        out.indent(2) do
          render_source_comment(out, union)
          out.puts <<~HEREDOC
            def __init__(
                self,
                #{union.discriminant.name.underscore}: #{type_hint_string union.discriminant, union_name},
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

            out.puts "self.#{union.discriminant.name.underscore} = #{union.discriminant.name.underscore}"
            union.arms.each do |arm|
              next if arm.void?
              out.puts "self.#{arm.name.underscore} = #{arm.name.underscore}"
            end
          end
          out.puts "def pack(self, packer: Packer) -> None:"
          out.indent(2) do
            out.puts "#{encode_type union.discriminant, union.discriminant.name.underscore}"
            union.normal_arms.each do |arm|
              arm.cases.each do |c|
                if c.value.is_a?(AST::Identifier)
                  out.puts "if self.#{union.discriminant.name.underscore} == #{type_string union.discriminant.type}.#{c.value.name}:"
                else
                  out.puts "if self.#{union.discriminant.name.underscore} == #{c.value.value}:"
                end
                out.indent(2) do
                  if arm.void?
                    out.puts "return"
                  else
                    encode_member arm, out, true
                    out.puts "return"
                  end
                end
              end
            end
            # if union.default_arm.present?
            # end
            #
          end

          out.puts "@classmethod"
          out.puts "def unpack(cls, unpacker: Unpacker) -> \"#{union_name}\":"
          out.indent(2) do
            out.puts "#{union.discriminant.name.underscore} = #{decode_type union.discriminant}"
            union.normal_arms.each do |arm|
              arm.cases.each do |c|
                if c.value.is_a?(AST::Identifier)
                  out.puts "if #{union.discriminant.name.underscore} == #{type_string union.discriminant.type}.#{c.value.name}:"
                else
                  out.puts "if #{union.discriminant.name.underscore} == #{c.value.value}:"
                end
                out.indent(2) do
                  if arm.void?
                    out.puts "return cls(#{union.discriminant.name.underscore}=#{union.discriminant.name.underscore})"
                  else
                    decode_member arm, out
                    out.puts "return cls(#{union.discriminant.name.underscore}=#{union.discriminant.name.underscore}, #{arm.name.underscore}=#{arm.name.underscore})"
                  end
                end
              end
            end
            out.puts "return cls(#{union.discriminant.name.underscore}=#{union.discriminant.name.underscore})"

            # if union.default_arm.present?
            #   out.puts "return cls(#{union.discriminant.name.underscore}=#{union.discriminant.name.underscore})"
            # end
          end

          render_xdr_utils(out, union_name)
          attribute_names = []
          attribute_names.push(union.discriminant.name.underscore)
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
            out.puts "out.append(f'#{union.discriminant.name.underscore}={self.#{union.discriminant.name.underscore}}')"
            union.arms.each do |arm|
              next if arm.void?
              out.puts "out.append(f'#{arm.name.underscore}={self.#{arm.name.underscore}}') if self.#{arm.name.underscore} is not None else None"
            end
            out.puts "return f\"<#{union_name} {[', '.join(out)]}>\""
          end
        end
        out.close
      end

      def render_struct(init_out, struct)
        struct_name = name struct
        init_out.puts "from .#{struct_name.underscore} import #{struct_name}"

        file_name = "#{struct_name.underscore}.py"
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
              out.puts "self.#{member.name.underscore} = #{member.name.underscore}"
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
                out.puts "#{member.name.underscore}=#{member.name.underscore},"
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

        if member.type.sub_type == :optional
          out.puts <<~HEREDOC
            if self.#{member.name.underscore} is None:
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
                if self.#{member.name.underscore} is None:
                    raise ValueError("#{member.name.underscore} should not be None.")
              HEREDOC
            end
            if member.declaration.fixed?
              _, size = member.declaration.type.array_size
              out.puts "packer.pack_uint(#{size})"
            else
              out.puts "packer.pack_uint(len(self.#{member.name.underscore}))"
            end
            out.puts <<~HEREDOC
              for item in self.#{member.name.underscore}:
                  item.pack(packer)
            HEREDOC
          else
            if member.type.sub_type == :optional or is_union_member
              out.puts <<~HEREDOC
                if self.#{member.name.underscore} is None:
                    raise ValueError("#{member.name.underscore} should not be None.")
              HEREDOC
            end
            out.puts "#{encode_type member.declaration, "#{member.name.underscore}"}"
          end
        end
      end

      def decode_member(member, out)
        case member.declaration
        when AST::Declarations::Void;
          out.puts "return"
        end
        case member.declaration
        when AST::Declarations::Array
          out.puts <<-EOS.strip_heredoc
            length = unpacker.unpack_uint()
            #{member.name.underscore} = []
            for _ in range(length):
                #{member.name.underscore}.append(#{decode_type(member.declaration)})
          EOS
        else
          if member.type.sub_type == :optional
            out.puts "#{member.name.underscore} = #{decode_type member.declaration} if unpacker.unpack_uint() else None"
          else
            out.puts "#{member.name.underscore} = #{decode_type member.declaration}"
            # out.puts <<~HEREDOC
            #   if #{member.name.underscore} is None:
            #       raise ValueError("#{member.name.underscore} should not be None.")
            # HEREDOC
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
          if member.declaration.fixed?
            out.puts <<~HEREDOC
              if #{member.name.underscore} and len(#{member.name.underscore}) != #{size}:
                  raise ValueError(f\"The length of `#{member.name.underscore}` should be #{size}, but got {len(#{member.name.underscore})}.\")
            HEREDOC
          else
            out.puts <<~HEREDOC
              if #{member.name.underscore} and len(#{member.name.underscore}) > #{size || MAX_SIZE}:
                  raise ValueError(f\"The maximum length of `#{member.name.underscore}` should be #{size || MAX_SIZE}, but got {len(#{member.name.underscore})}.\")
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

        out.puts <<-EOS.strip_heredoc
          from xdrlib import Packer, Unpacker

          __all__ = ["Integer", "UnsignedInteger", "Float", "Double", "Hyper", "UnsignedHyper", "Boolean", "String", "Opaque"]


          class Integer:
              def __init__(self, value: int) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_int(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> int:
                  return unpacker.unpack_int()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<Integer [value={self.value}]>"
          
          
          class UnsignedInteger:
              def __init__(self, value: int) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_uint(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> int:
                  return unpacker.unpack_uint()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<UnsignedInteger [value={self.value}]>"
          
          
          class Float:
              def __init__(self, value: float) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_float(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> float:
                  return unpacker.unpack_float()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<Float [value={self.value}]>"
          
          
          class Double:
              def __init__(self, value: float) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_double(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> float:
                  return unpacker.unpack_double()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<Double [value={self.value}]>"
          
          
          class Hyper:
              def __init__(self, value: int) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_hyper(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> int:
                  return unpacker.unpack_hyper()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<Hyper [value={self.value}]>"
          
          
          class UnsignedHyper:
              def __init__(self, value: int) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_uhyper(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> int:
                  return unpacker.unpack_uhyper()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<UnsignedHyper [value={self.value}]>"
          
          
          class Boolean:
              def __init__(self, value: bool) -> None:
                  self.value = value
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_bool(self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> bool:
                  return unpacker.unpack_bool()
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value
          
              def __str__(self):
                  return f"<Boolean [value={self.value}]>"
          
          
          class String:
              def __init__(self, value: bytes, size: int) -> None:
                  if len(value) > size:
                      raise ValueError(
                          f"The maximum length of `value` should be {size}, but got {len(value)}."
                      )
          
                  self.value = value
                  self.size = len(value)
          
              def pack(self, packer: Packer) -> None:
                  packer.pack_uint(len(self.value))
                  packer.pack_fopaque(len(self.value), self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker) -> bytes:
                  size = unpacker.unpack_uint()
                  return unpacker.unpack_fopaque(size)
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return self.value == other.value and self.size == other.size
          
              def __str__(self):
                  return f"<String [value={self.value}, size={self.size}]>"
          
          
          class Opaque:
              def __init__(self, value: bytes, size: int, fixed: bool) -> None:
                  if fixed:
                      if len(value) != size:
                          raise ValueError(
                              f"The length of `value` should be {size}, but got {len(value)}."
                          )
                  else:
                      if len(value) > size:
                          raise ValueError(
                              f"The maximum length of `value` should be {size}, but got {len(value)}."
                          )
          
                  self.value = value
                  self.fixed = fixed
                  self.size = len(value)
          
              def pack(self, packer: Packer) -> None:
                  if not self.fixed:
                      size = len(self.value)
                      packer.pack_uint(size)
                  else:
                      size = self.size
                  packer.pack_fopaque(size, self.value)
          
              @staticmethod
              def unpack(unpacker: Unpacker, size: int, fixed: bool) -> bytes:
                  if not fixed:
                      size = unpacker.unpack_uint()
                  return unpacker.unpack_fopaque(size)
          
              def __eq__(self, other: object) -> bool:
                  if not isinstance(other, self.__class__):
                      return NotImplemented
                  return (
                          self.value == other.value
                          and self.fixed == other.fixed
                          and self.size == other.size
                  )
          
              def __str__(self):
                  return f"<Opaque [value={self.value}, fixed={self.fixed}, size={self.size}]>"

        EOS
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

      def type_hint_string(decl, container_name)
        self_type_hint = type_string(decl.type) == container_name
        case decl.type.sub_type
        when :optional
          if self_type_hint
            "Optional[\"#{type_string decl.type}\"]"
          else
            "Optional[#{type_string decl.type}]"
          end
        when :var_array, :array
          if self_type_hint
            "List[\"#{type_string decl.type}\"]"
          else
            "List[#{type_string decl.type}]"
          end
        else
          if self_type_hint
            "\"#{type_string decl.type}\""
          else
            "#{type_string decl.type}"
          end
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
          "#{name type}"
        when AST::Definitions::Base
          "#{name type}"
        when AST::Concerns::NestedDefinition
          "#{name type}"
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end
      end

      private

      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)
        result = named.name.camelize
        "#{parent}#{result}"
      end
    end
  end
end