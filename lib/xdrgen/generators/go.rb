module Xdrgen
  module Generators

    class Go < Xdrgen::Generators::Base

      Primitive = Struct.new(:name, :go_type) do
        def sub_type
          :simple
        end
      end
      PRIMITIVES = [
        Primitive.new("Int",    "int32"),
        Primitive.new("Uint",   "uint32"),
        Primitive.new("Hyper",  "int64"),
        Primitive.new("Uhyper", "uint64"),
        Primitive.new("Float",  "float32"),
        Primitive.new("Double", "float64"),
        Primitive.new("Bool",   "bool"),
      ]

      def generate
        path = "#{@namespace}_generated.go"
        out = @output.open(path)

        render_common
        render_top_matter out
        render_definitions(out, @top)
      end

      private

      def render_common
        template = IO.read(__dir__ + "/go/xdr_common.go.erb")
        result = ERB.new(template).result binding
        IO.write(@output.output_dir +  "/xdr_common.go", result)
      end

      def render_typedef(out, typedef)
        out.puts "type #{name typedef} #{decl_string(typedef.declaration)}"

        out.puts <<-EOS.strip_heredoc
          func Decode#{name typedef}(decoder *xdr.Decoder, result *#{name typedef}) (int, error) {
            var (
              val #{ type_string typedef.declaration.type }
              totalRead int
              bytesRead int
              err       error
            )

            #{decode_into typedef.declaration.type, "val"}

            *result = #{name typedef}(val)
            return totalRead, nil
          }
        EOS

        out.puts optional_decoder(typedef)
        out.puts fixed_array_decoder(typedef)
        out.puts array_decoder(typedef)
        out.break

        cast = case
          when typedef.type.is_a?(AST::Typespecs::Opaque) && typedef.type.decl.fixed?
            "(*#{type_string typedef.type})(value)"
          when typedef.type.is_a?(AST::Typespecs::Opaque)
            "(#{type_string typedef.type})(*value)"
          when typedef.sub_type == :simple
            "(*#{type_string typedef.type})(value)"
          when typedef.sub_type == :optional
            "(*#{type_string typedef.type})(value)"
          when typedef.sub_type == :array
            "((#{type_string typedef.type})*value)"
          when typedef.sub_type == :var_array
            "((#{type_string typedef.type})*value)"
          else
            "typedef error: cannot figure out how to cast value" 
          end

        # render encode function
        out.puts <<-EOS.strip_heredoc
          func Encode#{name typedef}(encoder *xdr.Encoder, value *#{name typedef}) (int, error) {
            var (
              totalWritten int
              bytesWritten int
              err       error
            )

            #{encode_from typedef.declaration.type, cast}

            return totalWritten, err
          }
        EOS

        out.puts optional_encoder(typedef)
        out.puts fixed_array_encoder(typedef)
        out.puts array_encoder(typedef)
        out.break
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
        render_nested_definitions(out, defn)
        render_source_comment(out, defn)

        case defn
        when AST::Definitions::Struct ;
          render_struct out, defn
        when AST::Definitions::Enum ;
          render_enum out, defn
        when AST::Definitions::Union ;
          render_union out, defn
        when AST::Definitions::Typedef ;
          render_typedef out, defn
        when AST::Definitions::Const ;
          render_const out, defn
        end
      end

      def render_source_comment(out, defn)
        return if defn.is_a?(AST::Definitions::Namespace)

        out.puts <<-EOS.strip_heredoc
          // === xdr source ============================================================
          //
        EOS

        out.puts "//   " + defn.text_value.split("\n").join("\n//   ")
        
        out.puts <<-EOS.strip_heredoc
          //
          // ===========================================================================

        EOS
      end

      def render_struct(out, struct)
        out.puts "type #{name struct} struct {"
        out.indent do

          struct.members.each do |m|
            out.puts "#{name m} #{decl_string(m.declaration)}"
          end

        end
        out.puts "}"
        out.break

        # render decode function

        field_decoders = struct.members.map{|m| decode_member(m)}.join("\n")

        out.puts <<-EOS.strip_heredoc
          func Decode#{name struct}(decoder *xdr.Decoder, result *#{name struct}) (int, error) {
            totalRead := 0
            bytesRead := 0
            var err error

            #{field_decoders}

            return totalRead, nil
          }
        EOS

        out.puts optional_decoder(struct)
        out.puts fixed_array_decoder(struct)
        out.puts array_decoder(struct)

        # render encode function
        
        field_encoders = struct.members.map{|m| encode_member(m)}.join("\n")

        out.puts <<-EOS.strip_heredoc
          func Encode#{name struct}(encoder *xdr.Encoder, value *#{name struct}) (int, error) {
            totalWritten := 0
            bytesWritten := 0
            var err error

            #{field_encoders}

            return totalWritten, nil
          }
        EOS

        out.puts optional_encoder(struct)
        out.puts fixed_array_encoder(struct)
        out.puts array_encoder(struct)
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
            out.puts "#{name enum}#{name m} = #{m.value}"
          end
        end
        out.puts ")"

        # render the map used by xdr to decide valid values
        out.puts "var #{name enum}Map = map[int32]bool{"
        out.indent do

          enum.members.each do |m|
            out.puts "#{m.value}: true,"
          end

        end
        out.puts "}"

        # render decode function
        out.puts <<-EOS.strip_heredoc
          func Decode#{name enum}(decoder *xdr.Decoder, result *#{name enum}) (int, error) {
            val, bytesRead, err := decoder.DecodeEnum(#{name enum}Map)

            if err != nil {
              return bytesRead, err
            }
            *result = #{name enum}(val)
            return bytesRead, err
          }
        EOS

        out.puts optional_decoder(enum)
        out.puts fixed_array_decoder(enum)
        out.puts array_decoder(enum)
        out.break

        # render encode function
        out.puts <<-EOS.strip_heredoc
          func Encode#{name enum}(encoder *xdr.Encoder, value *#{name enum}) (int, error) {
            bytesWritten, err := encoder.EncodeEnum(int32(*value),#{name enum}Map)
            return bytesWritten, err
          }
        EOS

        out.puts optional_encoder(enum)
        out.puts fixed_array_encoder(enum)
        out.puts array_encoder(enum)
        out.break
      end

      def render_union(out, union)
        out.puts "type #{name union} struct{"
        out.indent do
          out.puts "#{private_name union.discriminant} #{type_string union.discriminant.type}"

          union.arms.each do |arm|
            next if arm.void?

            storage_class = case arm.type.sub_type
              when :simple ;
                "*#{type_string arm.type}"
              when :var_array ;
                "*[]#{type_string arm.type}"
              when :array ;
                "*[#{arm.type.size}]#{type_string arm.type}"
              when :optional
                "*#{type_string arm.type}"
              else
                raise "unknown sub_type: #{arm.type.sub_type}"
              end

            out.puts "#{private_name arm} #{storage_class}"
          end



        end
        out.puts "}"
        out.break

        if union.discriminant_type.blank?
          raise "Cannot find definition for #{union.discriminant.type.name}"
        end

        # for each member in the discrimant
        #   find what arm 
        union.discriminant_type.members.each do |m|
          out.puts union_constructor(union, m)
        end

        
        # Add discriminant accessor
        out.puts <<-EOS
          func (u *#{name union})#{name union.discriminant}() #{type_string union.discriminant.type} {
            return u.#{private_name union.discriminant}
          } 
        EOS

        # Add accessors for of form val, ok := union.ArmName()

        union.arms.each do |arm|
          next if arm.void?
          out.puts access_arm(arm)
        end

        # render decoder
        case_decoders = union.discriminant_type.members.map do |m|
          decode_case(union, m)
        end

        out.puts <<-EOS.strip_heredoc
          func Decode#{name union}(decoder *xdr.Decoder, result *#{name union}) (int, error) {
            var (
              discriminant #{name union.discriminant_type}
              totalRead int
              bytesRead int
              err       error
            )
            
            #{decode_into union.discriminant_type, "discriminant"}
            
            #{case_decoders.join("\n\n")}
            
            return totalRead, nil
          }
        EOS

        out.puts optional_decoder(union)
        out.puts fixed_array_decoder(union)
        out.puts array_decoder(union)

        out.break

        case_encoders = union.discriminant_type.members.map do |m|
          encode_case(union, m)
        end

        out.puts <<-EOS.strip_heredoc
          func Encode#{name union}(encoder *xdr.Encoder, value *#{name union}) (int, error) {
            var (
              totalWritten int
              bytesWritten int
              err       error
            )
            
            #{encode_from union.discriminant_type, "&value.#{private_name union.discriminant}"}

            #{case_encoders.join("\n\n")}
            
            return totalWritten, nil
          }
        EOS

        out.puts optional_encoder(union)
        out.puts fixed_array_encoder(union)
        out.puts array_encoder(union)

        out.break
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Automatically generated from #{@output.source_paths.join(",")}
          // DO NOT EDIT or your changes may be overwritten
        
          package #{@namespace || "main"}

          import (
            "errors"
            "fmt"
            "github.com/davecgh/go-xdr/xdr2"
          )
        EOS
        out.break
      end

      private

      def decl_string(decl)
        case decl
        when AST::Declarations::Opaque ;
          size = decl.fixed? ? decl.size : ""
          "[#{size}]byte"
        when AST::Declarations::String ;
          "string"
        when AST::Declarations::Array ;
          size = decl.fixed? ? decl.size : ""
          "[#{size}]#{type_string decl.type}"
        when AST::Declarations::Optional ;
          "*#{type_string(decl.type)}"
        when AST::Declarations::Simple ;
          type_string(decl.type)
        else
          raise "Unknown declaration type: #{decl.class.name}"
        end
      end

      def type_string(type)
        case type
        when AST::Typespecs::Int ;
          "int32"
        when AST::Typespecs::UnsignedInt ;
          "uint32"
        when AST::Typespecs::Hyper ;
          "int64"
        when AST::Typespecs::UnsignedHyper ;
          "uint64"
        when AST::Typespecs::Float ;
          "float32"
        when AST::Typespecs::Double ;
          "float64"
        when AST::Typespecs::Quadruple ;
          raise "cannot render quadruple in golang"
        when AST::Typespecs::Bool ;
          "bool"
        when AST::Typespecs::Opaque ;
          "[#{type.size}]byte"
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

        # NOTE: classify will strip plurality, so we restore it if necessary
        plural = named.name.pluralize == named.name
        base   = named.name.underscore.classify
        result = plural ? base.pluralize : base

        "#{parent}#{result}"
      end

      def private_name(named)
        # NOTE: classify will strip plurality, so we restore it if necessary
        plural = named.name.pluralize == named.name
        base   = escape_name named.name.underscore.camelize(:lower)
        plural ? base.pluralize : base
      end

      def escape_name(name)
        case name
        when "type" ; "aType"
        when "func" ; "aFunc"
        else ; name
        end
      end

      def decode(type, result_binding="result")
        result = "Decode"
        result << "Optional" if type.sub_type == :optional
          
        result << case type
          when AST::Typespecs::Int ;
            "Int"
          when AST::Typespecs::UnsignedInt ;
            "Uint"
          when AST::Typespecs::Hyper ;
            "Hyper"
          when AST::Typespecs::UnsignedHyper ;
            "Uhyper"
          when AST::Typespecs::Float ;
            "Float"
          when AST::Typespecs::Double ;
            "Double"
          when AST::Typespecs::Quadruple ;
            raise "cannot render quadruple in golang"
          when AST::Typespecs::Bool ;
            "Bool"
          when AST::Typespecs::Opaque ;
            "FixedOpaque"
          when AST::Typespecs::String ;
            "String"
          when AST::Concerns::NestedDefinition ;
            name type
          else
            name type
          end

          result << case 
            when type.is_a?(AST::Typespecs::Opaque) ;
              "(decoder, #{result_binding}[:], #{size type.size})"
            when type.is_a?(AST::Typespecs::String) ;
              "(decoder, &#{result_binding}, #{size type.size})"
            when type.sub_type == :simple ;
              "(decoder, &#{result_binding})"
            when type.sub_type == :optional ;
              "(decoder, &#{result_binding})"
            when type.sub_type == :array ;
              "FixedArray(decoder, &#{result_binding}, #{size type.decl.size})"
            when :var_array ;
              "Array(decoder, &#{result_binding}, #{size type.decl.size})"
            else ;
              raise "unexpected subtype: #{type.sub_type}"
            end

        result
      end

      def encode(type, value_binding="value")
        result = "Encode"
        result << "Optional" if type.sub_type == :optional
          
        result << case type
          when AST::Typespecs::Int ;
            "Int"
          when AST::Typespecs::UnsignedInt ;
            "Uint"
          when AST::Typespecs::Hyper ;
            "Hyper"
          when AST::Typespecs::UnsignedHyper ;
            "Uhyper"
          when AST::Typespecs::Float ;
            "Float"
          when AST::Typespecs::Double ;
            "Double"
          when AST::Typespecs::Quadruple ;
            raise "cannot render quadruple in golang"
          when AST::Typespecs::Bool ;
            "Bool"
          when AST::Typespecs::Opaque ;
            type.decl.fixed? ? "FixedOpaque" : "Opaque"
          when AST::Typespecs::String ;
            "String"
          when AST::Concerns::NestedDefinition ;
            name type
          else
            name type
          end

          result << case 
            when type.is_a?(AST::Typespecs::Opaque) ;
              "(encoder, #{value_binding}[:], #{size type.size})"
            when type.is_a?(AST::Typespecs::String) ;
              "(encoder, #{value_binding}, #{size type.size})"
            when type.sub_type == :simple ;
              "(encoder, #{value_binding})"
            when type.sub_type == :optional ;
              "(encoder, #{value_binding})"
            when type.sub_type == :array ;
              "FixedArray(encoder, #{value_binding}, #{size type.decl.size})"
            when :var_array ;
              "Array(encoder, #{value_binding}, #{size type.decl.size})"
            else ;
              raise "unexpected subtype: #{type.sub_type}"
            end

        result
      end

      def decode_into(type, result_binding)
        <<-EOS
          bytesRead, err = #{decode type, result_binding}
          totalRead += bytesRead
          if err != nil {
            return totalRead, err
          }
        EOS
      end

      def encode_from(type, value_binding)
        <<-EOS
          bytesWritten, err = #{encode type, value_binding}
          totalWritten += bytesWritten
          if err != nil {
            return totalWritten, err
          }
        EOS
      end

      def decode_member(m)
        case m.type.sub_type
        when :simple, :array, :var_array
          decode_into(m.type, "result.#{name m}")
        when :optional
          <<-EOS.strip_heredoc
            var #{private_name m} *#{type_string m.type}
            #{decode_into m.type, private_name(m)}
            result.#{name m} = #{private_name m}
          EOS
        else
          raise "unknown sub_type: #{m.type.sub_type}"
        end
      end

      def encode_member(m)
        case
        when m.type.is_a?(AST::Typespecs::Opaque)
          encode_from(m.type, "value.#{name m}[:]")
        when m.type.sub_type == :simple
          encode_from(m.type, "&value.#{name m}")
        when m.type.sub_type ==:array
          encode_from(m.type, "value.#{name m}[:]")
        when m.type.sub_type == :var_array
          encode_from(m.type, "value.#{name m}[:]")
        when m.type.sub_type == :optional
          encode_from(m.type, "value.#{name m}")
        else
          raise "unknown sub_type: #{m.type.sub_type}"
        end
      end

      def decode_case(union, kase)
        # lookup the arm
        arm = union.normal_arms.find{|a| a.cases.any?{|c| c == kase.name}}
        arm ||= union.default_arm
        return "" if arm.nil?
        return "" if arm.void?

        dname    = private_name union.discriminant
        dtype    = union.discriminant_type
        go_const = "#{name dtype}#{name kase}"

        case_storage = case arm.type.sub_type
          when :simple ;
            type_string arm.type
          when :var_array ;
            "[]#{type_string arm.type}"
          when :array ;
            "[#{arm.type.size}]#{type_string arm.type}"
          when :optional
            "*#{type_string arm.type}"
          else
            raise "unknown sub_type: #{arm.type.sub_type}"
          end

        # require 'pry' ; binding.pry if arm.type.sub_type == :var_array
        <<-EOS.strip_heredoc

          if discriminant == #{go_const} {
            var #{private_name kase} #{case_storage}
            #{decode_into(arm.type, private_name(kase))}
            *result = New#{name union}#{name kase}(#{private_name kase})
          }
        EOS
      end

      def encode_case(union, kase)
        # lookup the arm
        arm = union.normal_arms.find{|a| a.cases.any?{|c| c == kase.name}}
        arm ||= union.default_arm
        return "" if arm.nil?
        return "" if arm.void?

        dname    = private_name union.discriminant
        dtype    = union.discriminant_type
        go_const = "#{name dtype}#{name kase}"

        value_binding = case arm.type.sub_type
          when :simple ;
            "value.#{private_name arm}"
          when :var_array ;
            "(*value.#{private_name arm})[:]"
          when :array ;
            "(*value.#{private_name arm})[:]"
          when :optional
            "value.#{private_name arm}"
          else
            raise "unknown sub_type: #{arm.type.sub_type}"
          end

        <<-EOS.strip_heredoc
          if value.#{dname} == #{go_const} {
            #{encode_from(arm.type, value_binding)}
          }
        EOS
      end

      def optional_decoder(named, result_type=name(named))
        <<-EOS
        func DecodeOptional#{name named}(decoder *xdr.Decoder, result **#{result_type}) (int, error) {
            var (
              isPresent bool
              totalRead int
              bytesRead int
              err       error
            )

            bytesRead, err = DecodeBool(decoder, &isPresent)
            totalRead += bytesRead

            if err != nil {
              return totalRead, err
            }

            if !isPresent {
              return totalRead, err
            }

            var val #{result_type}

            #{decode_into named, "val"}

            *result = &val

            return totalRead, nil
          }
        EOS
      end

      def optional_encoder(named, result_type=name(named))
        <<-EOS
        func EncodeOptional#{name named}(encoder *xdr.Encoder, value *#{result_type}) (int, error) {
            var (
              isPresent bool
              totalWritten int
              bytesWritten int
              err       error
            )
            isPresent = value != nil
            bytesWritten, err = EncodeBool(encoder, &isPresent)
            totalWritten += bytesWritten

            if err != nil {
              return totalWritten, err
            }

            if !isPresent {
              return totalWritten, nil
            }

            #{encode_from named, "value"}

            return totalWritten, nil
          }
        EOS
      end

      def fixed_array_decoder(named, result_type=name(named))
        <<-EOS
          func Decode#{name named}FixedArray(decoder *xdr.Decoder, result []#{result_type}, size int) (int, error) {
            var (
              totalRead int
              bytesRead int
              err       error
            )

            if len(result) != size {
              errMsg := fmt.Sprintf("xdr: bad array len:%d, expected %d", len(result), size)
              return 0, errors.New(errMsg)
            }

            for i := 0; i < size; i++ {
              #{decode_into named, "result[i]"}
            }

            return totalRead, nil
          }
        EOS
      end

      def fixed_array_encoder(named, result_type=name(named))
        <<-EOS
          func Encode#{name named}FixedArray(encoder *xdr.Encoder, value []#{result_type}, size int) (int, error) {
            var (
              totalWritten int
              bytesWritten int
              err          error
            )

            if len(value) != int(size) {
              errMsg := fmt.Sprintf("xdr: value wrong size:%d, expected:%d", len(value), size)
              return 0, errors.New(errMsg)   
            }

            for _, element := range value {
              #{encode_from named, "&element"}
            }

            return totalWritten, nil
          }
        EOS
      end

      def array_decoder(named, result_type=name(named))
        <<-EOS

          func Decode#{name named}Array(decoder *xdr.Decoder, result *[]#{result_type}, maxSize int32) (int, error) {
            var (
              size      int32
              totalRead int
              bytesRead int
              err       error
            )

            bytesRead, err = DecodeInt(decoder, &size)
            totalRead += bytesRead

            if err != nil {
              return totalRead, err
            }

            if size > maxSize {
              errMsg := fmt.Sprintf("xdr: encoded array size too large:%d, max:%d", size, maxSize)
              return totalRead, errors.New(errMsg)
            }

            var theResult = make([]#{result_type}, size)
            *result = theResult

            for i := int32(0); i < size; i++ {
              #{decode_into named, "theResult[i]"}
            }

            return totalRead, nil
          }

          EOS
      end

      def array_encoder(named, result_type=name(named))
        <<-EOS

          func Encode#{name named}Array(encoder *xdr.Encoder, value []#{result_type}, maxSize int32) (int, error) {
            var (
              size         int32
              totalWritten int
              bytesWritten int
              err          error
            )
            
            size = int32(len(value))

            if size > maxSize {
              errMsg := fmt.Sprintf("xdr: value too large:%d, max:%d", size, maxSize)
              return totalWritten, errors.New(errMsg)
            }

            bytesWritten, err = EncodeInt(encoder, &size)
            totalWritten += bytesWritten

            if err != nil {
              return totalWritten, err
            }

            for _, element := range value {
              #{encode_from named, "&element"}
            }

            return totalWritten, nil
          }

        EOS
      end

      def union_constructor(union, kase)
        # lookup the arm
        arm = union.normal_arms.find{|a| a.cases.any?{|c| c == kase.name}}
        arm ||= union.default_arm
        return "" if arm.nil?

        dname    = private_name union.discriminant
        dtype    = union.discriminant_type
        go_const = "#{name dtype}#{name kase}"

        constructor_name  = "New#{name union}#{name kase}"
        discriminant_init = "#{dname}: #{go_const},"

        args, arm_init = case
          when arm.void? ;
            ["",""]
          when arm.type.sub_type == :simple ;
            ["val #{type_string arm.type}", "#{private_name arm}:&val,"]
          when arm.type.sub_type == :var_array ;
            ["val []#{type_string arm.type}", "#{private_name arm}:&val,"]
          when arm.type.sub_type == :array ;
            ["val [#{arm.type.size}]#{type_string arm.type}", "#{private_name arm}:&val,"]
          when arm.type.sub_type == :optional
            ["val *#{type_string arm.type}", "#{private_name arm}:val,"]
          else
            raise "unknown sub_type: #{arm.type.sub_type}"
          end

        <<-EOS.strip_heredoc
          func #{constructor_name}(#{args}) #{name union} {
            return #{name union}{
              #{discriminant_init}
              #{arm_init}
            }
          }
        EOS
      end

      def access_arm(arm)
        result_type = case
        when arm.type.sub_type == :simple ;
          type_string arm.type
        when arm.type.sub_type == :var_array ;
          "[]#{type_string arm.type}"
        when arm.type.sub_type == :array ;
          "[#{arm.type.size}]#{type_string arm.type}"
        when arm.type.sub_type == :optional
          "*#{type_string arm.type}"
        else
          raise "unknown sub_type: #{arm.type.sub_type}"
        end

        <<-EOS.strip_heredoc
          func (u *#{name arm.union})#{name arm}() #{result_type} {
            return *u.#{private_name arm}
          }
        EOS
      end

      def size(size_s)
        result = size_s
        result = "MaxXdrElements" if result.blank?
        result
      end
    end
  end
end