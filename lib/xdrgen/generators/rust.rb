module Xdrgen
  module Generators

    class Rust < Xdrgen::Generators::Base

      def generate
        @already_rendered = []
        path = "#{@namespace}.rs"
        out = @output.open(path)

        @type_field_types = build_type_field_types(@top)

        render_top_matter(out)
        render_lib(out)
        render_definitions(out, @top)
        out.break
      end

      private

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
        EOS
        out.puts "//  #{@output.source_paths.join("\n//  ")}"
        out.break
      end

      def render_lib(out)
        lib = IO.read(__dir__ + "/rust/src/lib.rs")
        out.puts(lib)
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
        out.puts "#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
        out.puts "pub struct #{name struct} {"
        out.indent do
          struct.members.each do |m|
            out.puts "pub #{field_name m}: #{reference(struct, m.declaration.type)},"
          end
        end
        out.puts "}"
        out.puts ""
        out.puts <<-EOS.strip_heredoc
        impl ReadXDR for #{name struct} {
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                Ok(Self{
                  #{struct.members.map do |m|
                    "#{field_name(m)}: #{reference_to_call(struct, m.declaration.type, :read)}::read_xdr(r)?,"
                  end.join("\n")}
                })
            }
        }

        impl WriteXDR for #{name struct} {
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                #{struct.members.map do |m|
                  "self.#{field_name(m)}.write_xdr(w)?;"
                end.join("\n")}
                Ok(())
            }
        }
        EOS
        out.break
      end

      def render_enum(out, enum)
        out.puts "// enum"
        out.puts "#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
        out.puts "#[repr(i32)]"
        out.puts "pub enum #{name enum} {"
        out.indent do
          enum.members.each do |m|
            out.puts "#{name m} = #{m.value},"
          end
        end
        out.puts '}'
        out.puts ""
        out.puts <<-EOS.strip_heredoc
        impl TryFrom<i32> for #{name enum} {
            type Error = Error;

            fn try_from(i: i32) -> std::result::Result<Self, Self::Error> {
                let e = match i {
                    #{enum.members.map do |m| "#{m.value} => #{name enum}::#{name m}," end.join("\n")}
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<#{name enum}> for i32 {
            fn from(e: #{name enum}) -> Self {
                e as Self
            }
        }

        impl ReadXDR for #{name enum} {
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                let e = i32::read_xdr(r)?;
                let v: Self = e.try_into()?;
                Ok(v)
            }
        }

        impl WriteXDR for #{name enum} {
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                let i: i32 = (*self).into();
                i.write_xdr(w)
            }
        }
        EOS
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
                case_name = kase.value.name.underscore.camelize
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
        out.puts "#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
        out.puts "pub enum #{name union} {"
        out.indent do
          # TODO: Add handling of default arms.
          union_cases(union) do |case_name, arm|
            out.puts arm.void? ? "#{case_name}#{"(())" unless arm.void?}," : "#{case_name}(#{reference(union, arm.type)}),"
          end
        end
        out.puts '}'
        out.puts ""
        out.puts <<-EOS.strip_heredoc
        impl #{name union} {
            pub fn discriminant(&self) -> #{discriminant_type} {
                match self {
                    #{union_cases(union) do |case_name, arm, value|
                      value.nil? ? "Self::#{case_name}#{"(_)" unless arm.void?} => #{discriminant_type}::#{case_name}," :
                      discriminant_type_builtin ? "Self::#{case_name}#{"(_)" unless arm.void?} => #{value},"
                                 : "Self::#{case_name}#{"(_)" unless arm.void?} => #{discriminant_type}(#{value}),"
                    end.join("\n")}
                }
            }
        }

        impl ReadXDR for #{name union} {
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                let dv: #{discriminant_type} = <#{discriminant_type} as ReadXDR>::read_xdr(r)?;
                let v = match #{discriminant_type_builtin ? "dv" : "dv.into()"} {
                    #{union_cases(union) do |case_name, arm, value|
                      if arm.void?
                        value.nil? ? "#{discriminant_type}::#{case_name} => Self::#{case_name},"
                                  : "#{value} => Self::#{case_name},"
                      else
                        value.nil? ? "#{discriminant_type}::#{case_name} => Self::#{case_name}(#{reference_to_call(union, arm.type, :read)}::read_xdr(r)?),"
                                  : "#{value} => Self::#{case_name}(#{reference_to_call(union, arm.type, :read)}::read_xdr(r)?),"
                      end
                    end.join("\n")}
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(v)
            }
        }

        impl WriteXDR for #{name union} {
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                self.discriminant().write_xdr(w)?;
                match self {
                    #{union_cases(union) do |case_name, arm, value|
                      if arm.void?
                        "Self::#{case_name} => ().write_xdr(w)?,"
                      else
                        "Self::#{case_name}(v) => v.write_xdr(w)?,"
                      end
                    end.join("\n")}
                };
                Ok(())
            }
        }
        EOS
        out.break
      end

      def render_typedef(out, typedef)
        if is_builtin_type(typedef.type)
          out.puts "pub type #{name typedef} = #{reference(typedef, typedef.type)};"
        else
          out.puts "#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
          out.puts "pub struct #{name typedef}(pub #{reference(typedef, typedef.type)});"
          out.puts ""
          out.puts <<-EOS.strip_heredoc
          impl From<#{name typedef}> for #{reference(typedef, typedef.type)} {
              fn from(x: #{name typedef}) -> Self {
                  x.0
              }
          }

          impl From<#{reference(typedef, typedef.type)}> for #{name typedef} {
              fn from(x: #{reference(typedef, typedef.type)}) -> Self {
                  #{name typedef}(x)
              }
          }

          impl AsRef<#{reference(typedef, typedef.type)}> for #{name typedef} {
              fn as_ref(&self) -> &#{reference(typedef, typedef.type)} {
                  &self.0
              }
          }

          impl ReadXDR for #{name typedef} {
              fn read_xdr(r: &mut impl Read) -> Result<Self> {
                  let i = #{reference_to_call(typedef, typedef.type, :read)}::read_xdr(r)?;
                  let v = #{name typedef}(i);
                  Ok(v)
              }
          }

          impl WriteXDR for #{name typedef} {
              fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                  self.0.write_xdr(w)
              }
          }
          EOS
        end
        out.break
      end

      def render_const(out, const)
        out.puts "pub const #{name(const).underscore.upcase}: u64 = #{const.value};"
        out.break
      end

      def is_builtin_type(type)
        [
          AST::Typespecs::Bool,
          AST::Typespecs::Double, AST::Typespecs::Float,
          AST::Typespecs::UnsignedHyper, AST::Typespecs::UnsignedInt,
          AST::Typespecs::Hyper, AST::Typespecs::Int,
          AST::Typespecs::String,
        ].any? { |t| t === type }
      end

      def base_reference(type)
        case type
        when AST::Typespecs::Bool
          'bool'
        when AST::Typespecs::Double
          'f64'
        when AST::Typespecs::Float
          'f32'
        when AST::Typespecs::UnsignedHyper
          'u64'
        when AST::Typespecs::UnsignedInt
          'u32'
        when AST::Typespecs::Hyper
          'i64'
        when AST::Typespecs::Int
          'i32'
        when AST::Typespecs::Quadruple
          raise 'no quadruple support for rust'
        when AST::Typespecs::String
          if !type.decl.resolved_size.nil?
            "VecM::<u8, #{type.decl.resolved_size}>"
          else
            "Vec::<u8>"
          end
        when AST::Typespecs::Opaque
          if type.fixed?
            "[u8; #{type.size}]"
          elsif !type.decl.resolved_size.nil?
            "VecM::<u8, #{type.decl.resolved_size}>"
          else
            "Vec::<u8>"
          end
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          if type.respond_to?(:resolved_type) && AST::Definitions::Typedef === type.resolved_type && is_builtin_type(type.resolved_type.type)
            base_reference(type.resolved_type.type)
          else
            name type
          end
        else
          raise "Unknown reference type: #{type.class.name}, #{type.class.ancestors}"
        end
      end

      def reference(parent, type)
        base_ref = base_reference type

        case type.sub_type
        when :simple
          base_ref
        when :optional
          parent_name = name(parent) if parent
          if is_type_in_type_field_types(base_ref, parent_name)
            "Option<Box<#{base_ref}>>"
          else
            "Option<#{base_ref}>"
          end
        when :array
          is_named, size = type.array_size
          size = name @top.find_definition(size) if is_named
          "[#{base_ref}; #{size}]"
        when :var_array
          if !type.decl.resolved_size.nil?
            "VecM::<#{base_ref}, #{type.decl.resolved_size}>"
          else
            "Vec::<#{base_ref}>"
          end
        else
          raise "Unknown sub_type: #{type.sub_type}"
        end
      end

      def base_reference_to_call(type, op)
        case type
        when AST::Typespecs::String
          if !type.decl.resolved_size.nil?
            "VecM::<u8, #{type.decl.resolved_size}>"
          else
            "Vec::<u8>"
          end
        when AST::Typespecs::Opaque
          if type.fixed?
            "[u8; #{type.size}]"
          elsif !type.decl.resolved_size.nil?
            "VecM::<u8, #{type.decl.resolved_size}>"
          else
            "Vec::<u8>"
          end
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          if type.respond_to?(:resolved_type) && AST::Definitions::Typedef === type.resolved_type && is_builtin_type(type.resolved_type.type)
            base_reference_to_call(type.resolved_type.type, op)
          else
            base_reference(type)
          end
        else
          base_reference(type)
        end
      end

      def reference_to_call(parent, type, op)
        base_ref = base_reference_to_call(type, op)

        ref = case type.sub_type
        when :simple
          base_ref
        when :optional
          parent_name = name(parent) if parent
          if is_type_in_type_field_types(base_ref, parent_name)
            "Option::<Box<#{base_ref}>>"
          else
            "Option::<#{base_ref}>"
          end
        when :array
          is_named, size = type.array_size
          size = name @top.find_definition(size) if is_named
          "[#{base_ref}; #{size}]"
        when :var_array
          if !type.decl.resolved_size.nil?
            "VecM::<#{base_ref}, #{type.decl.resolved_size}>"
          else
            "Vec::<#{base_ref}>"
          end
        else
          raise "Unknown sub_type: #{type.sub_type}"
        end

        "<#{ref}>"
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
