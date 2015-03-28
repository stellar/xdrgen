module Xdrgen
  module Generators

    class Go < Xdrgen::Generators::Base

      def generate
        basename = File.basename(@output.source_path, ".x")
        path = "#{basename}.go"
        out = @output.open(path)



        render_top_matter out
        render_definitions(out, @top)
        render_bottom_matter out
      end

      private

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



          func DecodeOptional#{name struct}(decoder *xdr.Decoder, optionalResult **#{name struct}) (int, error) {
            totalRead := 0
            bytesRead := 0
            var err error
            
            isPresent, bytesRead, err := decoder.DecodeBool()
            totalRead += bytesRead

            if err != nil {
              return totalRead, err
            }

            if !isPresent {
              return totalRead, err
            }
            var result #{name struct}

            #{field_decoders}

            *optionalResult = &result
            return totalRead, nil
          }
        EOS
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

            if err == nil {
              *result = #{name enum}(val)
            }
            return bytesRead, err
          }
        EOS

        out.break
      end

      def render_union(out, union)
        out.puts "type #{name union} struct{"
        out.indent do
          out.puts "#{name union.discriminant} #{type_string union.discriminant.type}"

          union.arms.each do |arm|
            next if arm.void?
            out.puts "#{private_name arm} *#{type_string arm.type}"
          end

        end
        out.puts "}"
        # Add accessors for of form val, ok := union.ArmName()

        union.arms.each do |arm|
          next if arm.void?
          out.puts <<-EOS.strip_heredoc
            func (u *#{name union})#{name arm}() *#{type_string arm.type} {
              //assert that the switch is one of the cases for this arm

              return u.#{private_name arm}
            }
          EOS
        end

        out.puts <<-EOS.strip_heredoc
          func Decode#{name union}(decoder *xdr.Decoder, result *#{name enum}) (int, error) {
            val, bytesRead, err := decoder.DecodeEnum(#{name enum}Map)

            if err == nil {
              *result = #{name enum}(val)
            }
            return bytesRead, err
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
            "github.com/davecgh/go-xdr/xdr2"
          )
        EOS
        out.break
      end

      def render_bottom_matter(out)

        primitives = {
          "Int"    => "int32",
          "Uint"   => "uint32",
          "Hyper"  => "int64",
          "Uhyper" => "uint64",
          "Float"  => "float32",
          "Double" => "float64",
          "Bool"   => "bool",
        }

        primitives.each do |xdr, go|
          out.puts <<-EOS.strip_heredoc

          
            func Decode#{xdr}(decoder *xdr.Decoder, result *#{go}) (int, error) {
              val, bytesRead, err := decoder.Decode#{xdr}()

              if err == nil {
                *result = val
              }

              return bytesRead, err
            }

            func DecodeOptional#{xdr}(decoder *xdr.Decoder, result **#{go}) (int, error) {
              
              isPresent, presenceBytesRead, err := decoder.DecodeBool()

              if err != nil {
                return presenceBytesRead, err
              }

              if !isPresent {
                return presenceBytesRead, err
              }

              val, bytesRead, err := decoder.Decode#{xdr}()

              if err == nil {
                *result = &val
              }

              return bytesRead + presenceBytesRead, err
            }

            EOS
        end

        out.break
      end

      private

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
        base   = named.name.underscore.camelize(:lower)
        plural ? base.pluralize : base
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

      def decoder(decl)

      end

    end
  end
end