module Xdrgen
  module Generators

    class Go < Xdrgen::Generators::Base

      def generate
        @already_rendered = []
        path = "#{@namespace}_generated.go"
        out = @output.open(path)

        render_top_matter out
        render_definitions(out, @top)
        render_bottom_matter out
      end

      private

      def render_typedef(out, typedef)
        out.puts "type #{name typedef} #{reference typedef.declaration.type}"


        # write sizing restrictions
        case typedef.declaration
        when Xdrgen::AST::Declarations::String
          render_maxsize_method out, typedef, typedef.declaration.resolved_size
        when Xdrgen::AST::Declarations::Opaque
          render_maxsize_method out, typedef, typedef.declaration.resolved_size
        when Xdrgen::AST::Declarations::Array
          unless typedef.declaration.fixed?
            render_maxsize_method out, typedef, typedef.declaration.resolved_size
          end
        end

        return unless typedef.sub_type == :simple

        resolved = typedef.resolved_type

        case resolved
        when AST::Definitions::Enum
          render_enum_typedef out, typedef, resolved
        when AST::Definitions::Union
          render_union_typedef out, typedef, resolved
        end

        out.break
      end

      def render_maxsize_method(out, typedef, size)
        return if size.blank?

        out.puts <<-EOS.strip_heredoc
          // XDRMaxSize implements the Sized interface for #{name typedef}
          func (e #{name typedef}) XDRMaxSize() int {
            return #{size}
          }
        EOS
      end

      def render_enum_typedef(out, typedef, enum)
        out.puts <<-EOS.strip_heredoc
          // ValidEnum validates a proposed value for this enum.  Implements
          // the Enum interface for #{name typedef}
          func (e #{name typedef}) ValidEnum(v int32) bool {
            return #{name enum}(e).ValidEnum(v)
          }
        EOS

        out.puts <<-EOS.strip_heredoc
          // String returns the name of `e`
          func (e #{name typedef}) String() string {
            return #{name enum}(e).String()
          }
        EOS

        out.break
      end

      def render_union_typedef(out, typedef, union)
        out.puts <<-EOS.strip_heredoc
          // SwitchFieldName returns the field name in which this union's
          // discriminant is stored
          func (u #{name typedef}) SwitchFieldName() string {
            return #{name union}(u).SwitchFieldName()
          }
        EOS

        out.break

        out.puts <<-EOS.strip_heredoc
          // ArmForSwitch returns which field name should be used for storing
          // the value for an instance of #{name union}
          func (u #{name typedef}) ArmForSwitch(sw int32) (string, bool) {
            return #{name union}(u).ArmForSwitch(sw)
          }
        EOS

        out.break

        constructor_name  = "New#{name typedef}"
        discriminant_arg = private_name union.discriminant
        discriminant_type = reference union.discriminant.type

        out.puts <<-EOS.strip_heredoc
          // #{constructor_name} creates a new  #{name typedef}.
          func #{constructor_name}(#{discriminant_arg} #{discriminant_type}, value interface{}) (result #{reference typedef}, err error) {
            u, err := New#{name union}(#{discriminant_arg}, value)
            result = #{name typedef}(u)
            return
          }
        EOS

        out.break

        # Add accessors for of form val, ok := union.GetArmName()
        # and val := union.MustArmName()
        union.arms.each do |arm|
          next if arm.void?
          out.puts   <<-EOS.strip_heredoc
            // Must#{name arm} retrieves the #{name arm} value from the union,
            // panicing if the value is not set.
            func (u #{name typedef}) Must#{name arm}() #{reference arm.type} {
              return #{name union}(u).Must#{name arm}()
            }

            // Get#{name arm} retrieves the #{name arm} value from the union,
            // returning ok if the union's switch indicated the value is valid.
            func (u #{name typedef}) Get#{name arm}() (result #{reference arm.type}, ok bool) {
              return #{name union}(u).Get#{name arm}()
            }
          EOS
        end

      end

      def render_const(out, const)
        out.puts "const #{name const} = #{const.value}"
        out.break
      end

      def render_definitions(out, node)
        node.definitions.each{|n| render_definition out, n }
        node.namespaces.each{|n| render_definitions out, n }
      end

      def render_nested_definitions(out, defn)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each{|ndefn| render_definition out, ndefn}
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
          render_binary_interface_struct out, defn
        when AST::Definitions::Enum ;
          render_enum out, defn
          render_binary_interface_enum out, defn
        when AST::Definitions::Union ;
          render_union out, defn
          render_binary_interface_union out, defn
        when AST::Definitions::Typedef ;
          render_typedef out, defn
          # TODO: Support defining binary interface on typedefs with optional
          # types. https://github.com/stellar/xdrgen/issues/61
          if defn.sub_type != :optional
            render_binary_interface_typedef out, defn
          end
        when AST::Definitions::Const ;
          render_const out, defn
        end
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
        out.puts "type #{name struct} struct {"
        out.indent do

          struct.members.each do |m|
            out.puts "#{name m} #{reference(m.declaration.type)} #{field_tag struct, m}"
          end

        end
        out.puts "}"
        out.break
      end

      def render_enum(out, enum)
        # render the "enum"
        out.puts "type #{name enum} int32"
        out.puts "const ("
        out.indent do
          first_member = enum.members.first
          out.puts "#{name enum}#{name first_member} #{name enum} = #{first_member.value}"

          rest_members = enum.members.drop(1)
          rest_members.each do |m|
            out.puts "#{name enum}#{name m} #{name enum} = #{m.value}"
          end
        end
        out.puts ")"

        # render the map used by xdr to decide valid values
        out.puts "var #{private_name enum}Map = map[int32]string{"
        out.indent do

          enum.members.each do |m|
            out.puts "#{m.value}: \"#{name enum}#{name m}\","
          end

        end
        out.puts "}"

        out.break

        out.puts <<-EOS.strip_heredoc
          // ValidEnum validates a proposed value for this enum.  Implements
          // the Enum interface for #{name enum}
          func (e #{name enum}) ValidEnum(v int32) bool {
            _, ok := #{private_name enum}Map[v]
            return ok
          }
        EOS

        out.puts <<-EOS.strip_heredoc
          // String returns the name of `e`
          func (e #{name enum}) String() string {
            name, _ := #{private_name enum}Map[int32(e)]
            return name
          }
        EOS

        out.break
      end

      def render_union(out, union)

        out.puts "type #{name union} struct{"
        out.indent do
          out.puts "#{name union.discriminant} #{reference union.discriminant.type}"

          union.arms.each do |arm|
            next if arm.void?
            out.puts "#{name arm} *#{reference arm.type} #{field_tag union, arm}"
          end
        end
        out.puts "}"
        out.break

        out.puts <<-EOS.strip_heredoc
          // SwitchFieldName returns the field name in which this union's
          // discriminant is stored
          func (u #{name union}) SwitchFieldName() string {
            return "#{name union.discriminant}"
          }
        EOS

        out.break

        out.puts <<-EOS.strip_heredoc
          // ArmForSwitch returns which field name should be used for storing
          // the value for an instance of #{name union}
          func (u #{name union}) ArmForSwitch(sw int32) (string, bool) {
        EOS

        switch_for(out, union, "sw") do |arm, kase|
          "return \"#{name arm unless arm.void?}\", true"
        end

        # when the default arm is not present, we must render the failure case
        unless union.default_arm.present?
          out.puts 'return "-", false'
        end

        out.puts "}"
        out.break

        # Add constructor of the form u := NewUnion(switch,val)
        render_union_constructor(out, union)

        # Add accessors for of form val, ok := union.GetArmName()
        # and val := union.MustArmName()
        union.arms.each do |arm|
          next if arm.void?
          out.puts access_arm(arm)
        end

        out.break
      end

      def render_binary_interface_struct(out, struct)
        name = name(struct)
        out.puts "func (s #{name}) EncodeInto(e *xdr.Encoder) error {"
        out.puts "  var err error"
        struct.members.each do |m|
          mn = name(m)
          mt = reference(m.declaration.type)
          ptr = m.declaration.type.sub_type == :optional
          simple = m.declaration.type.sub_type == :simple
          if (simple || ptr) && mt != "SponsorshipDescriptor" && mt != "string" && mt != "int32" && mt != "[32]byte"
            if ptr
              out.puts "  _, err = e.EncodeBool(s.#{mn} != nil)"
              out.puts "  if err != nil {"
              out.puts "    return err"
              out.puts "  }"
              out.puts "  if s.#{mn} != nil {"
              out.puts "    err = (*s.#{mn}).EncodeInto(e)"
              out.puts "  }"
            else
              out.puts "  err = s.#{mn}.EncodeInto(e)"
            end
          else
            out.puts "  _, err = e.Encode(s.#{mn})"
          end
          out.puts "  if err != nil {"
          out.puts "    return err"
          out.puts "  }"
        end
        out.puts "  return nil"
        out.puts "}"
        out.break
        out.puts "// MarshalBinary implements encoding.BinaryMarshaler."
        out.puts "func (s #{name}) MarshalBinary() ([]byte, error) {"
        out.puts "  b := bytes.Buffer{}"
        out.puts "  e := xdr.NewEncoder(&b)"
        out.puts "  err := s.EncodeInto(e)"
        out.puts "  return b.Bytes(), err"
        out.puts "}"
        out.break
        out.puts "// UnmarshalBinary implements encoding.BinaryUnmarshaler."
        out.puts "func (s *#{name}) UnmarshalBinary(inp []byte) error {"
        out.puts "  _, err := Unmarshal(bytes.NewReader(inp), s)"
        out.puts "  return err"
        out.puts "}"
        out.break
        out.puts "var ("
        out.puts "  _ encoding.BinaryMarshaler   = (*#{name})(nil)"
        out.puts "  _ encoding.BinaryUnmarshaler = (*#{name})(nil)"
        out.puts ")"
        out.break
      end

      def render_binary_interface_union(out, union)
        name = name(union)
        out.puts "func (s #{name}) EncodeInto(e *xdr.Encoder) error {"
        out.puts "  _, err := e.EncodeInt(int32(s.#{name(union.discriminant)}))"
        out.puts "  if err != nil {"
        out.puts "    return err"
        out.puts "  }"
        switch_for(out, union, "s.#{name(union.discriminant)}") do |arm, kase|
          out2 = StringIO.new
          if arm.void?
            "// Void"
          else
            mn = name(arm)
            if arm.type.sub_type == :optional
              out2.puts "  _, err = e.EncodeBool(s.#{mn} != nil)"
              out2.puts "  if err != nil {"
              out2.puts "    return err"
              out2.puts "  }"
              out2.puts "  if s.#{mn} != nil {"
              render_encode(out2, "(*s.#{mn})", arm.type, self_encode: false)
              out2.puts "  }"
            else
              render_encode(out2, "(*s.#{mn})", arm.type, self_encode: false)
            end
            out2.string
          end
        end
        out.puts "  return err"
        out.puts "}"
        out.break
        out.puts "// MarshalBinary implements encoding.BinaryMarshaler."
        out.puts "func (s #{name}) MarshalBinary() ([]byte, error) {"
        out.puts "  b := bytes.Buffer{}"
        out.puts "  e := xdr.NewEncoder(&b)"
        out.puts "  err := s.EncodeInto(e)"
        out.puts "  return b.Bytes(), err"
        out.puts "}"
        out.break
        out.puts "// UnmarshalBinary implements encoding.BinaryUnmarshaler."
        out.puts "func (s *#{name}) UnmarshalBinary(inp []byte) error {"
        out.puts "  _, err := Unmarshal(bytes.NewReader(inp), s)"
        out.puts "  return err"
        out.puts "}"
        out.break
        out.puts "var ("
        out.puts "  _ encoding.BinaryMarshaler   = (*#{name})(nil)"
        out.puts "  _ encoding.BinaryUnmarshaler = (*#{name})(nil)"
        out.puts ")"
        out.break
      end

      def render_binary_interface_enum(out, typedef)
        name = name(typedef)
        type = AST::Typespecs::Int
        render_binary_interface(out, name, type)
      end

      def render_binary_interface_typedef(out, typedef)
        name = name(typedef)
        type = typedef.declaration.type
        render_binary_interface(out, name, type)
      end

      def render_binary_interface(out, name, type)
        out.puts "func (s #{name}) EncodeInto(e *xdr.Encoder) error {"
        out.puts "  var err error"
        render_encode(out, "s", type, self_encode: true)
        out.puts "  return nil"
        out.puts "}"
        out.break
        out.puts "// MarshalBinary implements encoding.BinaryMarshaler."
        out.puts "func (s #{name}) MarshalBinary() ([]byte, error) {"
        out.puts "  b := bytes.Buffer{}"
        out.puts "  e := xdr.NewEncoder(&b)"
        out.puts "  err := s.EncodeInto(e)"
        out.puts "  return b.Bytes(), err"
        out.puts "}"
        out.break
        out.puts "// UnmarshalBinary implements encoding.BinaryUnmarshaler."
        out.puts "func (s *#{name}) UnmarshalBinary(inp []byte) error {"
        out.puts "  _, err := Unmarshal(bytes.NewReader(inp), s)"
        out.puts "  return err"
        out.puts "}"
        out.break
        out.puts "var ("
        out.puts "  _ encoding.BinaryMarshaler   = (*#{name})(nil)"
        out.puts "  _ encoding.BinaryUnmarshaler = (*#{name})(nil)"
        out.puts ")"
        out.break
      end

      # render_encode assumes there is an `e` variable containing an
      # xdr.Encoder, and a variable defined by `name` that is the value to
      # encode.
      def render_encode(out, var, type, self_encode:)
        case type
        when AST::Typespecs::UnsignedHyper
          out.puts "  _, err = e.EncodeUhyper(uint64(#{var}))"
        when AST::Typespecs::Hyper
          out.puts "  _, err = e.EncodeHyper(int64(#{var}))"
        when AST::Typespecs::UnsignedInt
          out.puts "  _, err = e.EncodeUint(uint32(#{var}))"
        when AST::Typespecs::Int
          out.puts "  _, err = e.EncodeInt(int32(#{var}))"
        when AST::Typespecs::String
          out.puts "  _, err = e.EncodeString(string(#{var}))"
        when AST::Typespecs::Opaque
          if type.fixed?
            out.puts "  _, err = e.EncodeFixedOpaque(#{var}[:])"
          else
            out.puts "  _, err = e.EncodeOpaque(#{var}[:])"
          end
        when AST::Typespecs::Simple
          case type.sub_type
          when :simple, :optional
            if self_encode
              out.puts "  err = #{name type}(#{var}).EncodeInto(e)"
            else
              out.puts "  err = #{var}.EncodeInto(e)"
            end
          when :array
            out.puts "  for i := 0; i < len(#{var}); i++ {"
            out.puts "    err = #{var}[i].EncodeInto(e)"
            out.puts "    if err != nil {"
            out.puts "      return err"
            out.puts "    }"
            out.puts "  }"
          when :var_array
            out.puts "  _, err = e.EncodeUint(uint32(len(#{var})))"
            out.puts "  if err != nil {"
            out.puts "    return err"
            out.puts "  }"
            out.puts "  for i := 0; i < len(#{var}); i++ {"
            out.puts "    err = #{var}[i].EncodeInto(e)"
            out.puts "    if err != nil {"
            out.puts "      return err"
            out.puts "    }"
            out.puts "  }"
          end
        when AST::Definitions::Base
          if self_encode
            out.puts "  err = #{name type}(#{var}).EncodeInto(e)"
          else
            out.puts "  err = #{var}.EncodeInto(e)"
          end
        else
          out.puts "  _, err = e.Encode(#{var})"
        end
        out.puts "  if err != nil {"
        out.puts "    return err"
        out.puts "  }"
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Package #{@namespace || "main"} is generated from:
          //
          //  #{@output.source_paths.join("\n//  ")}
          //
          // DO NOT EDIT or your changes may be overwritten
          package #{@namespace || "main"}

          import (
            "bytes"
            "encoding"
            "io"
            "fmt"

            "github.com/stellar/go-xdr/xdr3"
          )

          // Unmarshal reads an xdr element from `r` into `v`.
          func Unmarshal(r io.Reader, v interface{}) (int, error) {
            // delegate to xdr package's Unmarshal
          	return xdr.Unmarshal(r, v)
          }

          // Marshal writes an xdr element `v` into `w`.
          func Marshal(w io.Writer, v interface{}) (int, error) {
            if bm, ok := v.(encoding.BinaryMarshaler); ok {
              b, err := bm.MarshalBinary()
              if err != nil {
                return 0, err
              }
              return w.Write(b)
            } else {
              // delegate to xdr package's Marshal
              return xdr.Marshal(w, v)
            }
          }
        EOS
        out.break
      end

      def render_bottom_matter(out)
        out.puts <<-EOS
        var fmtTest = fmt.Sprint("this is a dummy usage of fmt")

        EOS
      end

      private

      def reference(type)
        baseReference = case type
        when AST::Typespecs::Bool
          "bool"
        when AST::Typespecs::Double
          "float64"
        when AST::Typespecs::Float
          "float32"
        when AST::Typespecs::Hyper
          "int64"
        when AST::Typespecs::Int
          "int32"
        when AST::Typespecs::Opaque
          if type.fixed?
            "[#{type.size}]byte"
          else
            "[]byte"
          end
        when AST::Typespecs::Quadruple
          raise "no quadruple support for go"
        when AST::Typespecs::String
          "string"
        when AST::Typespecs::UnsignedHyper
          "uint64"
        when AST::Typespecs::UnsignedInt
          "uint32"
        when AST::Typespecs::Simple
          name type
        when AST::Definitions::Base
          name type
        when AST::Concerns::NestedDefinition
          name type
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end

        case type.sub_type
        when :simple
          baseReference
        when :optional
          "*#{baseReference}"
        when :array
          is_named, size = type.array_size

          # if named, lookup the const definition
          if is_named
            size = name @top.find_definition(size)
          end

          "[#{size}]#{baseReference}"
        when :var_array
          "[#{size}]#{baseReference}"
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

        "#{parent}#{base.underscore.camelize}"
      end

      def private_name(named)
        escape_name named.name.underscore.camelize(:lower)
      end

      def escape_name(name)
        case name
        when "type" ; "aType"
        when "func" ; "aFunc"
        else ; name
        end
      end

      def render_union_constructor(out, union)
        constructor_name  = "New#{name union}"


        discriminant_arg = private_name union.discriminant
        discriminant_type = reference union.discriminant.type

        out.puts <<-EOS.strip_heredoc
          // #{constructor_name} creates a new  #{name union}.
          func #{constructor_name}(#{discriminant_arg} #{discriminant_type}, value interface{}) (result #{reference union}, err error) {
            result.#{name union.discriminant} = #{discriminant_arg}
        EOS

        switch_for(out, union, discriminant_arg) do |arm, kase|
          if arm.void?
            "// void"
          else
            <<-EOS
            tv, ok := value.(#{reference arm.type})
            if !ok {
              err = fmt.Errorf("invalid value, must be #{reference arm.type}")
              return
            }
            result.#{name arm} = &tv
            EOS
          end
        end

        out.puts <<-EOS.strip_heredoc
            return
          }
        EOS
      end

      def access_arm(arm)

        <<-EOS.strip_heredoc
          // Must#{name arm} retrieves the #{name arm} value from the union,
          // panicing if the value is not set.
          func (u #{name arm.union}) Must#{name arm}() #{reference arm.type} {
            val, ok := u.Get#{name arm}()

            if !ok {
              panic("arm #{name arm} is not set")
            }

            return val
          }

          // Get#{name arm} retrieves the #{name arm} value from the union,
          // returning ok if the union's switch indicated the value is valid.
          func (u #{name arm.union}) Get#{name arm}() (result #{reference arm.type}, ok bool) {
            armName, _ := u.ArmForSwitch(int32(u.#{name arm.union.discriminant}))

            if armName == "#{name arm}" {
              result = *u.#{name arm}
              ok = true
            }

            return
          }
        EOS
      end

      def size(size_s)
        result = size_s
        result = "MaxXdrElements" if result.blank?
        result
      end

      def switch_for(out, union, ident)
        out.puts "switch #{reference union.discriminant.type}(#{ident}) {"

        union.normal_arms.each do |arm|
          arm.cases.each do |c|

            value = if c.value.is_a?(AST::Identifier)
                      member = union.resolved_case(c)
                      if union.discriminant_type.nil? then
                        "int32(#{name member.enum}#{name member})"
                      else
                        "#{name union.discriminant_type}#{name member}"
                      end
                    else
                      c.value.text_value
                    end

            out.puts "    case #{value}:"
            out.puts "      #{yield arm, c}"
          end
        end

        if union.default_arm.present?
          arm = union.default_arm
          out.puts "    default:"
          out.puts "      #{yield arm, :default}"
        end

        out.puts "}"
      end

      def field_tag(struct, field)
        size = nil

        case field.declaration
        when Xdrgen::AST::Declarations::Opaque
          size = field.declaration.resolved_size
        when Xdrgen::AST::Declarations::String
          size = field.declaration.resolved_size
        when Xdrgen::AST::Declarations::Array
          size = field.declaration.resolved_size unless field.declaration.fixed?
        end

        return "`xdrmaxsize:\"#{size}\"`" if size.present?
      end

    end

  end
end
