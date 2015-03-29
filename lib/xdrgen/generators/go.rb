module Xdrgen
  module Generators

    class Go < Xdrgen::Generators::Base

      Primitive = Struct.new(:name, :go_type)
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
        basename = File.basename(@output.source_path, ".x")
        path = "#{basename}.go"
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
            var val #{ type_string typedef.declaration.type }

            bytesRead, err := #{decode typedef.declaration.type}(decoder, &val)

            if err == nil {
              *result = #{name typedef}(val)
            }

            return bytesRead, nil
          }
        EOS

        out.puts optional_decoder(typedef)
        out.puts fixed_array_decoder(typedef)
        out.puts array_decoder(typedef)
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

      def render_definition(out, defn)
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
      end

      def render_union(out, union)
        out.puts "type #{name union} struct{"
        out.indent do
          out.puts "#{private_name union.discriminant} #{type_string union.discriminant.type}"

          union.arms.each do |arm|
            next if arm.void?
            out.puts "#{private_name arm} *#{type_string arm.type}"
          end

        end
        out.puts "}"

        # TODO: Add constructors

        
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

        out.puts <<-EOS.strip_heredoc
          func Decode#{name union}(decoder *xdr.Decoder, result *#{name union}) (int, error) {
            var (
              discriminant #{name union.discriminant_type}
              totalRead int
              bytesRead int
            )

            bytesRead, err := #{decode union.discriminant_type}(decoder, &val)
            totalRead += bytesRead

            if err != nil {
              return totalRead, err
            }
            
            return totalRead, nil
          }
        EOS


        out.break
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Automatically generated from #{@output.source_path}
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
          "[#{size}]#{decl.child_type}"
        when AST::Declarations::Optional ;
          "*#{type_string(decl.type)}"
        when AST::Declarations::Simple ;
          type_string(decl.type)
        when AST::Declarations::Void ;
          "interface{} //TODO void"
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
        when AST::Typespecs::Simple ;
          name type
        when AST::Concerns::NestedDefinition ;
          "interface{} //TODO nested def"
        else
          raise "Unknown typespec: #{type.class.name}"
        end
      end

      def name(named)
        # NOTE: classify will strip plurality, so we restore it if necessary
        plural = named.name.pluralize == named.name
        base   = named.name.underscore.classify
        plural ? base.pluralize : base
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

      def decode(type, optional=false)
        result = "Decode"
        result << "Optional" if optional

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
          when AST::Concerns::NestedDefinition ;
            name type
          else
            name type
          end

        result
      end

      def decode_member(m)
        unless m.optional?
          <<-EOS.strip_heredoc

            bytesRead, err = #{decode m.type}(decoder, &result.#{name m})
            if err != nil {
              return totalRead, err
            }

            totalRead += bytesRead

          EOS
        else
          <<-EOS.strip_heredoc

            var #{private_name m} *#{type_string m.type}
            bytesRead, err = #{decode m.type, m.optional?}(decoder, &#{private_name m})
            if err != nil {
              return totalRead, err
            }
            
            totalRead += bytesRead
            result.#{name m} = #{private_name m}

          EOS
        end
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

            bytesRead, err = #{decode named}(decoder, &val)
            totalRead += bytesRead

            if err != nil {
              return totalRead, err
            }

            *result = &val

            return totalRead, nil
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
              bytesRead, err = Decode#{name named}(decoder, &result[i])

              if err != nil {
                return totalRead, err
              }

              totalRead += bytesRead
            }

            return totalRead, nil
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
              bytesRead, err = Decode#{name named}(decoder, &theResult[i])

              if err != nil {
                return totalRead, err
              }

              totalRead += bytesRead
            }

            return totalRead, nil
          }

          EOS
      end

      def access_arm(arm)
        <<-EOS.strip_heredoc
          func (u *#{name arm.union})#{name arm}() #{type_string arm.type} {
            //assert that the switch is one of the cases for this arm

            return *u.#{private_name arm}
          }
        EOS
      end

    end
  end
end