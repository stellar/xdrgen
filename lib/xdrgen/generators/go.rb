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
        # Typedefs that wrap a pointer type are not well supported in Go because
        # Go does not allow pointer types to have methods. This prevents us from
        # defining the EncodeTo method on these types which is very inconvenient
        # for the render functions that generate structs that contain these
        # types, because xdrgen doesn't know in that moment they are a type
        # without EncodeTo. Since this type cannot have its own methods, we make
        # it a type alias so at least it inherits the EncodeTo method from the
        # aliased type. This is a bit of a hack, and the hack will only work as
        # long as the aliased type is another defined type that has an EncodeTo.
        if typedef.sub_type == :optional
          out.puts "type #{name typedef} = #{reference typedef.declaration.type}"
        else
          out.puts "type #{name typedef} #{reference typedef.declaration.type}"
        end

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
          render_struct_encode_to_interface out, defn
          render_decoder_from_interface out, name(defn)
          render_struct_decode_from_interface out, defn
          render_binary_interface out, name(defn)
          render_xdr_type_interface out, name(defn)
        when AST::Definitions::Enum ;
          render_enum out, defn
          render_enum_encode_to_interface out, defn
          render_decoder_from_interface out, name(defn)
          render_enum_decode_from_interface out, defn
          render_binary_interface out, name(defn)
          render_xdr_type_interface out, name(defn)
        when AST::Definitions::Union ;
          render_union out, defn
          render_union_encode_to_interface out, defn
          render_decoder_from_interface out, name(defn)
          render_union_decode_from_interface out, defn
          render_binary_interface out, name(defn)
          render_xdr_type_interface out, name(defn)
        when AST::Definitions::Typedef ;
          render_typedef out, defn
          # Typedefs that wrap a pointer type are not supported in Go because Go
          # does not allow pointer types to have methods. Don't define methods
          # for the type because that will be a Go compiler error.
          if defn.sub_type != :optional
            render_typedef_encode_to_interface out, defn
            render_decoder_from_interface out, name(defn)
            render_typedef_decode_from_interface out, defn
            render_binary_interface out, name(defn)
            render_xdr_type_interface out, name(defn)
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

      def render_struct_encode_to_interface(out, struct)
        name = name(struct)
        out.puts "// EncodeTo encodes this value using the Encoder."
        out.puts "func (s *#{name}) EncodeTo(e *xdr.Encoder) error {"
        out.puts "  var err error"
        struct.members.each do |m|
          mn = name(m)
          render_encode_to_body(out, "s.#{mn}", m.type, self_encode: false)
        end
        out.puts "  return nil"
        out.puts "}"
        out.break
      end

      def render_union_encode_to_interface(out, union)
        name = name(union)
        out.puts "// EncodeTo encodes this value using the Encoder."
        out.puts "func (u #{name}) EncodeTo(e *xdr.Encoder) error {"
        out.puts "  var err error"
        render_encode_to_body(out, "u.#{name(union.discriminant)}", union.discriminant.type, self_encode: false)
        switch_for(out, union, "u.#{name(union.discriminant)}") do |arm, kase|
          out2 = StringIO.new
          if arm.void?
            out2.puts "// Void"
          else
            mn = name(arm)
            render_encode_to_body(out2, "(*u.#{mn})", arm.type, self_encode: false)
          end
          out2.puts "return nil"
          out2.string
        end

        # when the default arm is not present, we must render the failure case
        unless union.default_arm.present?
          out.puts "  return fmt.Errorf(\"#{name(union.discriminant)} (#{reference union.discriminant.type}) switch value '%d' is not valid for union #{name}\", u.#{name(union.discriminant)})"
        end

        out.puts "}"
        out.break
      end

      def render_enum_encode_to_interface(out, typedef)
        name = name(typedef)
        type = typedef
        out.puts <<-EOS.strip_heredoc
        // EncodeTo encodes this value using the Encoder.
        func (e #{name}) EncodeTo(enc *xdr.Encoder) error {
          if _, ok := #{private_name type}Map[int32(e)]; !ok {
            return fmt.Errorf("'%d' is not a valid #{name} enum value", e)
          }
          _, err := enc.EncodeInt(int32(e))
          return err
        }
        EOS
      end

      def is_fixed_array_type(type)
        (type.is_a?(AST::Typespecs::Opaque) && type.fixed?) || type.sub_type == :array
      end

      def render_typedef_encode_to_interface(out, typedef)
        name = name(typedef)
        type = typedef.declaration.type
        out.puts "// EncodeTo encodes this value using the Encoder."
        if is_fixed_array_type(type) ||
            (type.is_a?(AST::Identifier) && type.sub_type == :simple && type.resolved_type.is_a?(AST::Definitions::Typedef) && is_fixed_array_type(type.resolved_type.declaration.type))
          # Implement EncodeTo by pointer for Go array types
          # otherwise (if called by value), Go will make a heap allocation
          # for every by-value call since the copy required by the call
          # tends to escape the stack due to the large array sizes.
          out.puts "func (s *#{name}) EncodeTo(e *xdr.Encoder) error {"
        else
          out.puts "func (s #{name}) EncodeTo(e *xdr.Encoder) error {"
        end
        out.puts "  var err error"
        render_encode_to_body(out, "s", type, self_encode: true)
        out.puts "  return nil"
        out.puts "}"
        out.break
      end

      # render_encode_to_body assumes there is an `e` variable containing an
      # xdr.Encoder, and a variable defined by `var` that is the value to
      # encode.
      def render_encode_to_body(out, var, type, self_encode:)
        def check_error(str)
          <<-EOS
  if #{str}; err != nil {
    return err
  }
EOS
        end
        optional = type.sub_type == :optional
        if optional
          out.puts check_error "_, err = e.EncodeBool(#{var} != nil)"
          out.puts "  if #{var} != nil {"
          var = "(*#{var})"
        end
        case type
        when AST::Typespecs::UnsignedHyper
          out.puts check_error "  _, err = e.EncodeUhyper(uint64(#{var}))"
        when AST::Typespecs::Hyper
          out.puts check_error "_, err = e.EncodeHyper(int64(#{var}))"
        when AST::Typespecs::UnsignedInt
          out.puts check_error "_, err = e.EncodeUint(uint32(#{var}))"
        when AST::Typespecs::Int
          out.puts (check_error "_, err = e.EncodeInt(int32(#{var}))")
        when AST::Typespecs::Bool
          out.puts (check_error "_, err = e.EncodeBool(bool(#{var}))")
        when AST::Typespecs::String
          out.puts check_error "_, err = e.EncodeString(string(#{var}))"
        when AST::Typespecs::Opaque
          if type.fixed?
            out.puts check_error "_, err = e.EncodeFixedOpaque(#{var}[:])"
          else
            out.puts check_error "_, err = e.EncodeOpaque(#{var}[:])"
          end
        when AST::Typespecs::Simple
          case type.sub_type
          when :simple, :optional
            optional_within = type.is_a?(AST::Identifier) && type.resolved_type.sub_type == :optional
            if optional_within
              out.puts check_error "_, err = e.EncodeBool(#{var} != nil)"
              out.puts "  if #{var} != nil {"
              var = "(*#{var})"
            end
            if self_encode
              newvar = "#{name type}(#{var})"
              if type.resolved_type.is_a?(AST::Definitions::Typedef) && is_fixed_array_type(type.resolved_type.declaration.type)
                # Go array types implement EncodeTo by pointer
                if type.is_a?(AST::Identifier)
                  # we are already calling by pointer, so we just need to cast
                  newvar = "(*#{name type})(#{var})"
                else
                  newvar = "(*#{name type})(&#{var})"
                end
              end
              var = newvar
            end
            out.puts check_error "  err = #{var}.EncodeTo(e)"
            if optional_within
              out.puts "  }"
            end
          when :array
            out.puts "  for i := 0; i < len(#{var}); i++ {"
            element_var = "#{var}[i]"
            optional_within = type.is_a?(AST::Identifier) && type.resolved_type.sub_type == :optional
            if optional_within
              out.puts check_error "_, err = e.EncodeBool(#{element_var} != nil)"
              out.puts "    if #{element_var} != nil {"
              var = "(*#{element_var})"
            end
            out.puts check_error "err = #{element_var}.EncodeTo(e)"
            if optional_within
              out.puts "    }"
            end
            out.puts "  }"
          when :var_array
            out.puts check_error "_, err = e.EncodeUint(uint32(len(#{var})))"
            out.puts "  for i := 0; i < len(#{var}); i++ {"
            element_var = "#{var}[i]"
            optional_within = type.is_a?(AST::Identifier) && type.resolved_type.sub_type == :optional
            if optional_within
              out.puts check_error "_, err = e.EncodeBool(#{element_var} != nil)"
              out.puts "    if #{element_var} != nil {"
              var = "(*#{element_var})"
            end
            out.puts check_error "err = #{element_var}.EncodeTo(e)"
            if optional_within
              out.puts "    }"
            end
            out.puts "  }"
          else
            raise "Unknown sub_type: #{type.sub_type}"
          end
        when AST::Definitions::Base
          if self_encode
            out.puts check_error "err = #{name type}(#{var}).EncodeTo(e)"
          else
            out.puts check_error "err = #{var}.EncodeTo(e)"
          end
        else
          out.puts check_error "_, err = e.Encode(#{var})"
        end
        if optional
          out.puts "  }"
        end
      end

      def render_struct_decode_from_interface(out, struct)
        name = name(struct)
        out.puts "// DecodeFrom decodes this value using the Decoder."
        out.puts "func (s *#{name}) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {"
        out.puts "  if maxDepth == 0 {"
        out.puts "    return 0, fmt.Errorf(\"decoding #{name}: %w\", ErrMaxDecodingDepthReached)"
        out.puts "  }"
        out.puts "  maxDepth -= 1"
        out.puts "  var err error"
        out.puts "  var n, nTmp int"
        declared_variables = []
        struct.members.each do |m|
          mn = name(m)
          render_decode_from_body(out, "s.#{mn}", m.type, declared_variables: declared_variables, self_encode: false)
        end
        out.puts "  return n, nil"
        out.puts "}"
        out.break
      end

      def render_union_decode_from_interface(out, union)
        name = name(union)
        out.puts "// DecodeFrom decodes this value using the Decoder."
        out.puts "func (u *#{name}) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {"
        out.puts "  if maxDepth == 0 {"
        out.puts "    return 0, fmt.Errorf(\"decoding #{name}: %w\", ErrMaxDecodingDepthReached)"
        out.puts "  }"
        out.puts "  maxDepth -= 1"
        out.puts "  var err error"
        out.puts "  var n, nTmp int"
        render_decode_from_body(out, "u.#{name(union.discriminant)}", union.discriminant.type, declared_variables: [], self_encode: false)
        switch_for(out, union, "u.#{name(union.discriminant)}") do |arm, kase|
          out2 = StringIO.new
          if arm.void?
            out2.puts "// Void"
          else
            mn = name(arm)
            type = arm.type
            out2.puts "  u.#{mn} = new(#{reference arm.type})"
            render_decode_from_body(out2, "(*u.#{mn})",type, declared_variables: [], self_encode: false)
          end
          out2.puts "  return n, nil"
          out2.string
        end
        unless union.default_arm.present?
                    out.puts "  return n, fmt.Errorf(\"union #{name} has invalid #{name(union.discriminant)} (#{reference union.discriminant.type}) switch value '%d'\", u.#{name(union.discriminant)})"
        end
        out.puts "}"
        out.break
      end

      def render_enum_decode_from_interface(out, typedef)
        name = name(typedef)
        type = typedef
        out.puts <<-EOS.strip_heredoc
        // DecodeFrom decodes this value using the Decoder.
        func (e *#{name}) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {
          if maxDepth == 0 {
            return 0, fmt.Errorf("decoding #{name}: %w", ErrMaxDecodingDepthReached)
          }
          maxDepth -= 1
          v, n, err := d.DecodeInt()
          if err != nil {
            return n, fmt.Errorf("decoding #{name}: %w", err)
          }
          if _, ok := #{private_name type}Map[v]; !ok {
            return n, fmt.Errorf("'%d' is not a valid #{name} enum value", v)
          }
          *e = #{name}(v)
          return n, nil
        }
        EOS
      end

      def render_typedef_decode_from_interface(out, typedef)
        name = name(typedef)
        type = typedef.declaration.type
        out.puts "// DecodeFrom decodes this value using the Decoder."
        out.puts "func (s *#{name}) DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error) {"
        out.puts "  if maxDepth == 0 {"
        out.puts "    return 0, fmt.Errorf(\"decoding #{name}: %w\", ErrMaxDecodingDepthReached)"
        out.puts "  }"
        out.puts "  maxDepth -= 1"
        out.puts "  var err error"
        out.puts "  var n, nTmp int"
        var = "s"
        sub_var_type = ""
        case type
        when AST::Typespecs::UnsignedHyper, AST::Typespecs::Hyper, AST::Typespecs::UnsignedInt, AST::Typespecs::Int, AST::Typespecs::String
          sub_var_type = reference(type)
        end
        if (type.is_a?(AST::Typespecs::Opaque) && !type.fixed?) || (type.is_a?(AST::Typespecs::Simple) && type.sub_type == :var_array)
            var = "(*s)"
        end
        unless sub_var_type.empty?
          out.puts "  var v #{sub_var_type}"
          var = "v"
        end
        render_decode_from_body(out, var, type, declared_variables: [], self_encode: true)
        out.puts "  *s = #{name}(v)" unless sub_var_type.empty?
        out.puts "  return n, nil"
        out.puts "}"
        out.break
      end

      def render_variable_declaration(out, indent, var, type, declared_variables:)
        unless declared_variables.include?var
           out.puts "#{indent}var #{var} #{type}"
           declared_variables.append(var)
        end
      end

      # render_decode_from_body assumes there is an `d` variable containing an
      # xdr.Decoder, and a variable defined by `var` that is the value to
      # encode.
      def render_decode_from_body(out, var, type, declared_variables:, self_encode:)
        tail = <<-EOS
  n += nTmp
  if err != nil {
    return n, fmt.Errorf("decoding #{name type}: %w", err)
  }
EOS
        optional = type.sub_type == :optional
        if optional
          render_variable_declaration(out, "  ", 'b', "bool", declared_variables: declared_variables)
          out.puts "  b, nTmp, err = d.DecodeBool()"
          out.puts tail
          out.puts "  #{var} = nil"
          out.puts "  if b {"
          out.puts "     #{var} = new(#{name type})"
        end
        case type
        when AST::Typespecs::UnsignedHyper
          out.puts "  #{var}, nTmp, err = d.DecodeUhyper()"
          out.puts tail
        when AST::Typespecs::Hyper
          out.puts "  #{var}, nTmp, err = d.DecodeHyper()"
          out.puts tail
        when AST::Typespecs::UnsignedInt
          out.puts "  #{var}, nTmp, err = d.DecodeUint()"
          out.puts tail
        when AST::Typespecs::Int
          out.puts "  #{var}, nTmp, err = d.DecodeInt()"
          out.puts tail
        when AST::Typespecs::Bool
          out.puts "  #{var}, nTmp, err = d.DecodeBool()"
          out.puts tail
        when AST::Typespecs::String
          arg = "0"
          arg = type.decl.resolved_size unless type.decl.resolved_size.nil?
          out.puts "  #{var}, nTmp, err = d.DecodeString(#{arg})"
          out.puts tail
        when AST::Typespecs::Opaque
          if type.fixed?
            out.puts "  nTmp, err = d.DecodeFixedOpaqueInplace(#{var}[:])"
          else
            arg = "0"
            arg = type.decl.resolved_size unless type.decl.resolved_size.nil?
            out.puts "  #{var}, nTmp, err = d.DecodeOpaque(#{arg})"
          end
          out.puts tail
        when AST::Typespecs::Simple
          case type.sub_type
          when :simple, :optional
            optional_within = type.is_a?(AST::Identifier) && type.resolved_type.sub_type == :optional
            if optional_within
              render_variable_declaration(out, "  ", 'b', "bool", declared_variables: declared_variables)
              out.puts "  b, nTmp, err = d.DecodeBool()"
              out.puts tail
              out.puts "  #{var} = nil"
              out.puts "  if b {"
              out.puts "     #{var} = new(#{name type.resolved_type.declaration.type})"
            end
            var = "(*#{name type})(#{var})" if self_encode
            out.puts "  nTmp, err = #{var}.DecodeFrom(d, maxDepth)"
            out.puts tail
            if optional_within
              out.puts "  }"
            end
          when :array
            out.puts "  for i := 0; i < len(#{var}); i++ {"
            element_var = "#{var}[i]"
            optional_within = type.is_a?(AST::Identifier) && type.resolved_type.sub_type == :optional
            if optional_within
              out.puts "    var eb bool"
              out.puts "    eb, nTmp, err = d.DecodeBool()"
              out.puts tail
              out.puts "    #{var} = nil"
              out.puts "    if eb {"
              var = "(*#{element_var})"
            end
            out.puts "      nTmp, err = #{element_var}.DecodeFrom(d, maxDepth)"
            out.puts tail
            if optional_within
              out.puts "    }"
            end
            out.puts "  }"
          when :var_array
            render_variable_declaration(out, "  ", 'l', "uint32", declared_variables: declared_variables)
            out.puts "  l, nTmp, err = d.DecodeUint()"
            out.puts tail
            unless type.decl.resolved_size.nil?
               out.puts "  if l > #{type.decl.resolved_size} {"
               out.puts "    return n, fmt.Errorf(\"decoding #{name type}: data size (%d) exceeds size limit (#{type.decl.resolved_size})\", l)"
               out.puts "  }"
            end
            out.puts "  #{var} = nil"
            out.puts "  if l > 0 {"
            out.puts "    if il, ok := d.InputLen(); ok && uint(il) < uint(l) {"
            out.puts "        return n, fmt.Errorf(\"decoding #{name type}: length (%d) exceeds remaining input length (%d)\", l, il)"
            out.puts "    }"
            out.puts "    #{var} = make([]#{name type}, l)"
            out.puts "    for i := uint32(0); i < l; i++ {"
            element_var =   "#{var}[i]"
            optional_within = type.is_a?(AST::Identifier) && type.resolved_type.sub_type == :optional
            if optional_within
              out.puts "      var eb bool"
              out.puts "      eb, nTmp,  err = d.DecodeBool()"
              out.puts tail
              out.puts "      #{element_var} = nil"
              out.puts "      if eb {"
              out.puts "         #{element_var} = new(#{name type.resolved_type.declaration.type})"
              var = "(*#{element_var})"
            end
            out.puts "      nTmp, err = #{element_var}.DecodeFrom(d, maxDepth)"
            out.puts tail
            if optional_within
              out.puts "    }"
            end
            out.puts "    }"
            out.puts "  }"
          else
            raise "Unknown sub_type: #{type.sub_type}"
          end
        when AST::Definitions::Base
          if self_encode
            out.puts "  nTmp, err = #{name type}(#{var}).DecodeFrom(d, maxDepth)"
          else
            out.puts "  nTmp, err = #{var}.DecodeFrom(d, maxDepth)"
          end
          out.puts tail
        else
          out.puts "  nTmp, err = d.DecodeWithMaxDepth(&#{var}, maxDepth)"
          out.puts tail
        end
        if optional
           out.puts "  }"
        end
      end

      def render_binary_interface(out, name)
        out.puts "// MarshalBinary implements encoding.BinaryMarshaler."
        out.puts "func (s #{name}) MarshalBinary() ([]byte, error) {"
        out.puts "  b := bytes.Buffer{}"
        out.puts "  e := xdr.NewEncoder(&b)"
        out.puts "  err := s.EncodeTo(e)"
        out.puts "  return b.Bytes(), err"
        out.puts "}"
        out.break
        out.puts "// UnmarshalBinary implements encoding.BinaryUnmarshaler."
        out.puts "func (s *#{name}) UnmarshalBinary(inp []byte) error {"
        out.puts "  r := bytes.NewReader(inp)"
        out.puts "  o := xdr.DefaultDecodeOptions"
        out.puts "  o.MaxInputLen = len(inp)"
        out.puts "  d := xdr.NewDecoderWithOptions(r, o)"
        out.puts "  _, err := s.DecodeFrom(d, o.MaxDepth)"
        out.puts "  return err"
        out.puts "}"
        out.break
        out.puts "var ("
        out.puts "  _ encoding.BinaryMarshaler   = (*#{name})(nil)"
        out.puts "  _ encoding.BinaryUnmarshaler = (*#{name})(nil)"
        out.puts ")"
        out.break
      end

      def render_xdr_type_interface(out, name)
        out.puts "// xdrType signals that this type represents XDR values defined by this package."
        out.puts "func (s #{name}) xdrType() {}"
        out.break
        out.puts "var _ xdrType = (*#{name})(nil)"
        out.break
      end

      def render_decoder_from_interface(out, name)
        out.puts "var _ decoderFrom = (*#{name})(nil)"
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          //lint:file-ignore S1005 The issue should be fixed in xdrgen. Unfortunately, there's no way to ignore a single file in staticcheck.
          //lint:file-ignore U1000 fmtTest is not needed anywhere, should be removed in xdrgen.

          // Package #{@namespace || "main"} is generated from:
          //
          //  #{@output.relative_source_paths.join("\n//  ")}
          //
          // DO NOT EDIT or your changes may be overwritten
          package #{@namespace || "main"}

          import (
            "bytes"
            "encoding"
            "errors"
            "io"
            "fmt"

            "github.com/stellar/go-xdr/xdr3"
          )
        EOS
        out.break
        out.puts <<-EOS.strip_heredoc
        // XdrFilesSHA256 is the SHA256 hashes of source files.
        var XdrFilesSHA256 = map[string]string{
          #{@output.relative_source_path_sha256_hashes.map(){ |path, hash| %{"#{path}": "#{hash}",} }.join("\n")}
        }
        EOS
        out.break
        out.puts <<-EOS.strip_heredoc
          var ErrMaxDecodingDepthReached = errors.New("maximum decoding depth reached")

          type xdrType interface {
            xdrType()
          }

          type decoderFrom interface {
            DecodeFrom(d *xdr.Decoder, maxDepth uint) (int, error)
          }

          // Unmarshal reads an xdr element from `r` into `v`.
          func Unmarshal(r io.Reader, v interface{}) (int, error) {
            return UnmarshalWithOptions(r, v, xdr.DefaultDecodeOptions)
          }

          // UnmarshalWithOptions works like Unmarshal but uses decoding options.
          func UnmarshalWithOptions(r io.Reader, v interface{}, options xdr.DecodeOptions) (int, error) {
            if decodable, ok := v.(decoderFrom); ok {
              d := xdr.NewDecoderWithOptions(r, options)
              return decodable.DecodeFrom(d, options.MaxDepth)
            }
            // delegate to xdr package's Unmarshal
          	return xdr.UnmarshalWithOptions(r, v, options)
          }

          // Marshal writes an xdr element `v` into `w`.
          func Marshal(w io.Writer, v interface{}) (int, error) {
            if _, ok := v.(xdrType); ok {
              if bm, ok := v.(encoding.BinaryMarshaler); ok {
                b, err := bm.MarshalBinary()
                if err != nil {
                  return 0, err
                }
                return w.Write(b)
              }
            }
            // delegate to xdr package's Marshal
            return xdr.Marshal(w, v)
          }
        EOS
        out.break
      end

      def render_bottom_matter(out)
        out.puts 'var fmtTest = fmt.Sprint("this is a dummy usage of fmt")'
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
              err = errors.New("invalid value, must be #{reference arm.type}")
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
