module Xdrgen
  module Generators

    class Typescript < Xdrgen::Generators::Base

      def generate
        $stderr.puts "warn: typescript generator is experimental"

        @already_rendered = []
        path = "#{@namespace}.ts"
        out = @output.open(path)

        @types = build_type_list(@top)
        @type_field_types = build_type_field_types(@top)

        render_top_matter(out)
        render_lib(out)
        render_definitions(out, @top)
        render_enum_of_all_types(out, @types)
        out.break
      end

      private

      def build_type_list(node)
        types = Set.new
        ingest_node = lambda do |n|
          case n
          when AST::Definitions::Struct, AST::Definitions::Enum, AST::Definitions::Union, AST::Definitions::Typedef
            types << name(n)
          end
          n.definitions.each{ |nn| ingest_node.call(nn) } if n.respond_to?(:definitions)
          n.nested_definitions.each{ |nn| ingest_node.call(nn) } if n.respond_to?(:nested_definitions)
        end
        ingest_node.call(node)
        types
      end

      def build_type_field_types(node)
        types = Hash.new { |h, k| h[k] = [] }
        ingest_node = lambda do |n|
          n.definitions.each{ |nn| ingest_node.call(nn) } if n.respond_to?(:definitions)
          n.nested_definitions.each{ |nn| ingest_node.call(nn) } if n.respond_to?(:nested_definitions)
          case n
          when AST::Definitions::Struct
            n.members.each do |m|
              types[name(n)] << base_reference(m.declaration.type)
            end
          when AST::Definitions::Union ;
            union_cases(n) do |_, arm|
              types[name(n)] << base_reference(arm.type) unless arm.void?
            end
          end
        end
        ingest_node.call(node)
        types
      end

      # Determines if 'type' is referenced directly or indirectly by 'type_with_fields'.
      # Used to determine if 'type_with_fields' has a recursive relationship to 'type'.
      def is_type_in_type_field_types(type_with_fields, type, seen = [])
        return false if seen.include?(type_with_fields)
        seen << type_with_fields
        @type_field_types[type_with_fields].any? do |field_type|
          if field_type == type
            true
          else
            is_type_in_type_field_types(field_type, type, seen)
          end
        end
      end

      def render_top_matter(out)
        out.puts <<-EOS.strip_heredoc
          // Module #{@namepsace} is generated from:
          //  #{@output.relative_source_paths.join("\n//  ")}
        EOS
        out.break
        source_paths_sha256_hashes = @output.relative_source_path_sha256_hashes
        out.puts <<-EOS.strip_heredoc
          // `XDR_FILES_SHA256` is a list of pairs of source files and their SHA256 hashes.
          export const XDR_FILES_SHA256 = {
            #{source_paths_sha256_hashes.map(){ |path, hash| "\"#{path}\": \"#{hash}\"" }.join(",\n")}
          };
        EOS
        out.break
      end

      def render_lib(out)
        out.puts("import xdr from 'js-xdr';")
        out.puts("import { Buffer } from 'buffer';")
        out.break
        lib = IO.read(__dir__ + "/typescript/src/types.ts")
        out.puts(lib)
        out.break
      end

      def render_enum_of_all_types(out, types)
        out.puts "// enum of all types"
        out.break
      end

      def render_definitions(out, node)
        node.definitions.each{|n| render_definition out, n }
        node.namespaces.each{|n| render_definitions out, n }
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

      def render_nested_definitions(out, defn)
        return unless defn.respond_to? :nested_definitions
        defn.nested_definitions.each{|ndefn| render_definition out, ndefn}
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
        out.puts "export class #{name struct} {"
        out.indent do
          struct.members.each do |m|
            out.puts "#{field_name m}: #{reference(struct, m.declaration.type)};"
          end
        end
        out.break
        out.indent do
          out.puts <<-EOS.strip_heredoc
            static fromXDR(input: Buffer, format?: 'raw'): Buffer;
            static fromXDR(input: string, format: 'hex' | 'base64'): Buffer;
            static fromXDR(input: string | Buffer, format?: 'raw' | 'hex' | 'base64'): Buffer {
              if (typeof input === 'string') {
                return this.fromXDR(Buffer.from(input, format));
              }
              format = format ?? 'raw';
              throw new Error('not implemented');
            }

            static toXDR(value: #{name struct}): Buffer {
              throw new Error('not implemented');
            }

            static validateXDR(input: Buffer, format?: 'raw'): boolean;
            static validateXDR(input: string, format: 'hex' | 'base64'): boolean;
            static validateXDR(input: string | Buffer, format?: 'raw' | 'hex' | 'base64'): boolean {
              try {
                this.fromXDR(input, format);
                return true;
              } catch (e) {
                return false;
              }
            }

            toXDR(): Buffer {
              return #{name struct}.toXDR(this);
            }
          EOS
        end
        out.puts "}"
        out.break
      end

      def render_enum(out, enum)
        out.puts "export enum #{name enum} {"
        out.indent do
          enum.members.each do |m|
            out.puts "#{name m} = #{m.value},"
          end
        end
        out.puts '}'
        out.break
      end

      def union_is_idents(union)
        union.normal_arms.first&.cases.first&.value.is_a?(AST::Identifier)
      end

      def union_cases(union)
        results = []
        union.normal_arms.each do |arm|
          arm.cases.each do |kase|
              if kase.value.is_a?(AST::Identifier)
                case_name = kase.name_short.underscore.camelize
                value = nil
              else
                case_name = "V#{kase.value.value}"
                value = kase.value.value
              end
              results << yield(case_name, arm, value)
          end
        end
        results
      end

      def render_union(out, union)
        discriminant_type = reference(nil, union.discriminant.type)
        discriminant_type_builtin = is_builtin_type(union.discriminant.type) || (is_builtin_type(union.discriminant.type.resolved_type.type) if union.discriminant.type.respond_to?(:resolved_type) && AST::Definitions::Typedef === union.discriminant.type.resolved_type)
        out.puts "// union with discriminant #{discriminant_type}"
        out.puts "export type #{name union} = "
        union_case_count = 0
        out.indent do
          union_cases(union) do |case_name, arm|
            union_case_count += 1
            out.puts arm.void? ? "| #{case_name}#{"(())" unless arm.void?}" : "| #{case_name}(#{reference(union, arm.type)})"
          end
        end
        out.puts ';'
        out.break
      end

      def render_typedef(out, typedef)
        out.puts "type #{name typedef} = #{reference(nil, typedef.type)};"
        out.break
      end

      def render_const(out, const)
        out.puts "export const #{name(const).underscore.upcase} = #{const.value};"
        out.break
      end

      def is_builtin_type(type)
        [
          AST::Typespecs::Bool,
          AST::Typespecs::Double, AST::Typespecs::Float,
          AST::Typespecs::UnsignedHyper, AST::Typespecs::UnsignedInt,
          AST::Typespecs::Hyper, AST::Typespecs::Int,
        ].any? { |t| t === type }
      end

      def is_fixed_array_opaque(type)
        (AST::Typespecs::Opaque === type && type.fixed?)
      end

      def is_fixed_array_type(type)
        (AST::Typespecs::Opaque === type && type.fixed?) ||
        (type.sub_type == :array)
      end

      def is_var_array_type(type)
        (AST::Typespecs::Opaque === type && !type.fixed?) ||
        (AST::Typespecs::String === type) ||
        (type.sub_type == :var_array)
      end

      def base_reference(type)
        case type
        when AST::Typespecs::Bool
          'boolean'
        when AST::Typespecs::Double
          'number'
        when AST::Typespecs::Float
          'number'
        when AST::Typespecs::UnsignedHyper
          'bigint'
        when AST::Typespecs::UnsignedInt
          'number'
        when AST::Typespecs::Hyper
          'bigint'
        when AST::Typespecs::Int
          'number'
        when AST::Typespecs::Quadruple
          raise 'no quadruple support for typescript'
        when AST::Typespecs::String
          "string"
        when AST::Typespecs::Opaque
          "Buffer"
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          name type
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end
      end

      def reference(parent, type)
        base_ref = base_reference type

        parent_name = name(parent) if parent
        cyclic = is_type_in_type_field_types(base_ref, parent_name)

        case type.sub_type
        when :simple
          base_ref
        when :optional
          "Option<#{base_ref}>"
        when :array
          "Array<#{base_ref}>"
        when :var_array
          "Array<#{base_ref}>"
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
        base = escape_name(base)
        "#{parent}#{base.underscore.camelize}"
      end

      def field_name(named)
        escape_name named.name.underscore
      end

      def escape_name(name)
        case name
        when 'type' then 'type_'
        when 'Error' then 'SError'
        else name
        end
      end

    end
  end
end
