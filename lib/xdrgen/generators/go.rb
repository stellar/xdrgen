module Xdrgen
  module Generators

    class Go < Xdrgen::Generators::Base

      def generate
        @already_rendered = []
        path = "#{@namespace}_generated.go"
        out = @output.open(path)

        render_top_matter out
        render_definitions(out, @top)
      end

      private

      def render_typedef(out, typedef)
        out.puts "type #{name typedef} #{decl_string(typedef.declaration)}"
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
            out.puts "#{name m} #{decl_string(m.declaration)}"
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
            out.puts "#{name enum}#{name m} = #{m.value}"
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

        if union.discriminant_type.blank?
          raise "Cannot find definition for #{union.discriminant.type.name}"
        end

        out.puts "type #{name union} struct{"
        out.indent do
          out.puts "#{name union.discriminant} #{type_string union.discriminant.type}"

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

            out.puts "#{name arm} #{storage_class}"
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
            switch #{name union.discriminant_type}(sw) {
        EOS

        union.normal_arms.each do |arm|
          arm.resolved_cases.each do |c|
            out.puts "    case #{name union.discriminant_type}#{name c}:"
            out.puts "      return \"#{name arm unless arm.void?}\", true"
          end
        end

        if union.default_arm.present?
          arm = union.default_arm
          out.puts "    default:"
          out.puts "      return \"#{name arm unless arm.void?}\", true"
          out.puts <<-EOS.strip_heredoc
              }
            }
          EOS
        else
          out.puts <<-EOS.strip_heredoc
              }

              return "-", false
            }
          EOS
        end


        out.break

        # Add constructors of the form u := NewUnionArmName(val)
        union.discriminant_type.members.each do |m|
          out.puts union_constructor(union, m)
        end

        # Add accessors for of form val, ok := union.GetArmName()
        # and val := union.MustArmName()
        union.arms.each do |arm|
          next if arm.void?
          out.puts access_arm(arm)
        end

        out.break
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
            "io"

            "github.com/nullstyle/go-xdr/xdr3"
          )

          // Unmarshal reads an xdr element from `r` into `v`.
          func Unmarshal(r io.Reader, v interface{}) (int, error) {
            // delegate to xdr package's Unmarshal
          	return xdr.Unmarshal(r, v)
          }

          // Marshal writes an xdr element `v` into `w`.
          func Marshal(w io.Writer, v interface{}) (int, error) {
            // delegate to xdr package's Marshal
            return xdr.Marshal(w, v)
          }
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
        when AST::Typespecs::String ;
          "string"
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

      def union_constructor(union, kase)
        # lookup the arm
        arm = union.normal_arms.find{|a| a.cases.any?{|c| c == kase.name}}
        arm ||= union.default_arm
        return "" if arm.nil?

        dname    = name union.discriminant
        dtype    = union.discriminant_type
        go_const = "#{name dtype}#{name kase}"

        constructor_name  = "New#{name union}#{name kase}"
        discriminant_init = "#{dname}: #{go_const},"

        args, arm_init = case
          when arm.void? ;
            ["",""]
          when arm.type.sub_type == :simple ;
            ["val #{type_string arm.type}", "#{name arm}:&val,"]
          when arm.type.sub_type == :var_array ;
            ["val []#{type_string arm.type}", "#{name arm}:&val,"]
          when arm.type.sub_type == :array ;
            ["val [#{arm.type.size}]#{type_string arm.type}", "#{name arm}:&val,"]
          when arm.type.sub_type == :optional
            ["val *#{type_string arm.type}", "#{name arm}:val,"]
          else
            raise "unknown sub_type: #{arm.type.sub_type}"
          end

        <<-EOS.strip_heredoc
          // #{constructor_name} creates a new  #{name union}, initialized with
          // #{go_const} as the disciminant and the provided val
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
          // Must#{name arm} retrieves the #{name arm} value from the union,
          // panicing if the value is not set.
          func (u #{name arm.union}) Must#{name arm}() #{result_type} {
            val, ok := u.Get#{name arm}()

            if !ok {
              panic("arm #{name arm} is not set")
            }

            return val
          }

          // Get#{name arm} retrieves the #{name arm} value from the union,
          // returning ok if the union's switch indicated the value is valid.
          func (u #{name arm.union}) Get#{name arm}() (result #{result_type}, ok bool) {
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
    end
  end
end
