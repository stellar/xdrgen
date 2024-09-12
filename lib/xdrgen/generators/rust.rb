module Xdrgen
  module Generators

    class Rust < Xdrgen::Generators::Base

      def generate
        $stderr.puts "warn: rust generator is experimental"

        @already_rendered = []
        path = "#{@namespace}.rs"
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
        out.puts "#![allow(clippy::missing_errors_doc, clippy::unreadable_literal)]"
        out.break
        source_paths_sha256_hashes = @output.relative_source_path_sha256_hashes
        out.puts <<-EOS.strip_heredoc
          /// `XDR_FILES_SHA256` is a list of pairs of source files and their SHA256 hashes.
          pub const XDR_FILES_SHA256: [(&str, &str); #{source_paths_sha256_hashes.count}] = [
            #{source_paths_sha256_hashes.map(){ |path, hash| %{("#{path}", "#{hash}")} }.join(",\n")}
          ];
        EOS
        out.break
      end

      def render_lib(out)
        lib = IO.read(__dir__ + "/rust/src/types.rs")
        out.puts(lib)
        out.break
      end

      def render_enum_of_all_types(out, types)
        out.puts <<-EOS.strip_heredoc
        #[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
        #[cfg_attr(
          all(feature = "serde", feature = "alloc"),
          derive(serde::Serialize, serde::Deserialize),
          serde(rename_all = "snake_case")
        )]
        #[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
        pub enum TypeVariant {
            #{types.map { |t| "#{t}," }.join("\n")}
        }

        impl TypeVariant {
            pub const VARIANTS: [TypeVariant; #{types.count}] = [ #{types.map { |t| "TypeVariant::#{t}," }.join("\n")} ];
            pub const VARIANTS_STR: [&'static str; #{types.count}] = [ #{types.map { |t| "\"#{t}\"," }.join("\n")} ];

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn name(&self) -> &'static str {
                match self {
                    #{types.map { |t| "Self::#{t} => \"#{t}\"," }.join("\n")}
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variants() -> [TypeVariant; #{types.count}] {
                Self::VARIANTS
            }

            #[cfg(feature = "schemars")]
            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub fn json_schema(&self, gen: schemars::gen::SchemaGenerator) -> schemars::schema::RootSchema {
                match self {
                    #{types.map { |t| "Self::#{t} => gen.into_root_schema_for::<#{t}>()," }.join("\n")}
                }
            }
        }

        impl Name for TypeVariant {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<TypeVariant> for TypeVariant {
            fn variants() -> slice::Iter<'static, TypeVariant> {
                Self::VARIANTS.iter()
            }
        }

        impl core::str::FromStr for TypeVariant {
            type Err = Error;
            #[allow(clippy::too_many_lines)]
            fn from_str(s: &str) -> Result<Self> {
                match s {
                    #{types.map { |t| "\"#{t}\" => Ok(Self::#{t})," }.join("\n")}
                    _ => Err(Error::Invalid),
                }
            }
        }

        #[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
        #[cfg_attr(
          all(feature = "serde", feature = "alloc"),
          derive(serde::Serialize, serde::Deserialize),
          serde(rename_all = "snake_case"),
          serde(untagged),
        )]
        #[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
        pub enum Type {
            #{types.map { |t| "#{t}(Box<#{t}>)," }.join("\n")}
        }

        impl Type {
            pub const VARIANTS: [TypeVariant; #{types.count}] = [ #{types.map { |t| "TypeVariant::#{t}," }.join("\n")} ];
            pub const VARIANTS_STR: [&'static str; #{types.count}] = [ #{types.map { |t| "\"#{t}\"," }.join("\n")} ];

            #[cfg(feature = "alloc")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self> {
                match v {
                    #{types.map { |t| "TypeVariant::#{t} => r.with_limited_depth(|r| Ok(Self::#{t}(Box::new(#{t}::read_xdr(r)?))))," }.join("\n")}
                }
            }

            #[cfg(feature = "base64")]
            pub fn read_xdr_base64<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self> {
                let mut dec = Limited::new(base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD), r.limits.clone());
                let t = Self::read_xdr(v, &mut dec)?;
                Ok(t)
            }

            #[cfg(feature = "alloc")]
            pub fn read_xdr_to_end<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self> {
                let s = Self::read_xdr(v, r)?;
                // Check that any further reads, such as this read of one byte, read no
                // data, indicating EOF. If a byte is read the data is invalid.
                if r.read(&mut [0u8; 1])? == 0 {
                    Ok(s)
                } else {
                    Err(Error::Invalid)
                }
            }

            #[cfg(feature = "base64")]
            pub fn read_xdr_base64_to_end<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self> {
                let mut dec = Limited::new(base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD), r.limits.clone());
                let t = Self::read_xdr_to_end(v, &mut dec)?;
                Ok(t)
            }

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self>> + '_> {
                match v {
                    #{types.map { |t| "TypeVariant::#{t} => Box::new(ReadXdrIter::<_, #{t}>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::#{t}(Box::new(t)))))," }.join("\n")}
                }
            }

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_framed_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self>> + '_> {
                match v {
                    #{types.map { |t| "TypeVariant::#{t} => Box::new(ReadXdrIter::<_, Frame<#{t}>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::#{t}(Box::new(t.0)))))," }.join("\n")}
                }
            }

            #[cfg(feature = "base64")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_base64_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self>> + '_> {
                let dec = base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD);
                match v {
                    #{types.map { |t| "TypeVariant::#{t} => Box::new(ReadXdrIter::<_, #{t}>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::#{t}(Box::new(t)))))," }.join("\n")}
                }
            }

            #[cfg(feature = "alloc")]
            pub fn from_xdr<B: AsRef<[u8]>>(v: TypeVariant, bytes: B, limits: Limits) -> Result<Self> {
                let mut cursor = Limited::new(Cursor::new(bytes.as_ref()), limits);
                let t = Self::read_xdr_to_end(v, &mut cursor)?;
                Ok(t)
            }

            #[cfg(feature = "base64")]
            pub fn from_xdr_base64(v: TypeVariant, b64: impl AsRef<[u8]>, limits: Limits) -> Result<Self> {
                let mut b64_reader = Cursor::new(b64);
                let mut dec = Limited::new(base64::read::DecoderReader::new(&mut b64_reader, base64::STANDARD), limits);
                let t = Self::read_xdr_to_end(v, &mut dec)?;
                Ok(t)
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[deprecated(note = "use from_json")]
            pub fn read_json(v: TypeVariant, r: impl Read) -> Result<Self> {
                Self::from_json(v, r)
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[allow(clippy::too_many_lines)]
            pub fn from_json(v: TypeVariant, r: impl Read) -> Result<Self> {
                match v {
                    #{types.map { |t| "TypeVariant::#{t} => Ok(Self::#{t}(Box::new(serde_json::from_reader(r)?)))," }.join("\n")}
                }
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[allow(clippy::too_many_lines)]
            pub fn deserialize_json<'r, R: serde_json::de::Read<'r>>(v: TypeVariant, r: &mut serde_json::de::Deserializer<R>) -> Result<Self> {
                match v {
                    #{types.map { |t| "TypeVariant::#{t} => Ok(Self::#{t}(Box::new(serde::de::Deserialize::deserialize(r)?)))," }.join("\n")}
                }
            }

            #[cfg(feature = "alloc")]
            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub fn value(&self) -> &dyn core::any::Any {
                #[allow(clippy::match_same_arms)]
                match self {
                    #{types.map { |t| "Self::#{t}(ref v) => v.as_ref()," }.join("\n")}
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn name(&self) -> &'static str {
                match self {
                    #{types.map { |t| "Self::#{t}(_) => \"#{t}\"," }.join("\n")}
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variants() -> [TypeVariant; #{types.count}] {
                Self::VARIANTS
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variant(&self) -> TypeVariant {
                match self {
                    #{types.map { |t| "Self::#{t}(_) => TypeVariant::#{t}," }.join("\n")}
                }
            }
        }

        impl Name for Type {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<TypeVariant> for Type {
            fn variants() -> slice::Iter<'static, TypeVariant> {
                Self::VARIANTS.iter()
            }
        }

        impl WriteXdr for Type {
            #[cfg(feature = "alloc")]
            #[allow(clippy::too_many_lines)]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<()> {
                match self {
                    #{types.map { |t| "Self::#{t}(v) => v.write_xdr(w)," }.join("\n")}
                }
            }
        }
        EOS
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
          /// #{name defn} is an XDR #{defn.class.name.demodulize} defines as:
          ///
          /// ```text
        EOS

        out.puts "/// " + defn.text_value.split("\n").join("\n/// ")

        out.puts <<-EOS.strip_heredoc
          /// ```
          ///
        EOS
      end

      def render_struct(out, struct)
        out.puts "#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
        out.puts %{#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]}
        if @options[:rust_types_custom_str_impl].include?(name struct)
          out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr))]}
        else
          out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]}
        end
        if !@options[:rust_types_custom_jsonschema_impl].include?(name struct)
          out.puts %{#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]}
        end
        out.puts "pub struct #{name struct} {"
        out.indent do
          struct.members.each do |m|
            out.puts "pub #{field_name m}: #{reference(struct, m.declaration.type)},"
          end
        end
        out.puts "}"
        out.puts ""
        out.puts <<-EOS.strip_heredoc
        impl ReadXdr for #{name struct} {
            #[cfg(feature = "alloc")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self> {
                r.with_limited_depth(|r| {
                    Ok(Self{
                      #{struct.members.map do |m|
                        "#{field_name(m)}: #{reference_to_call(struct, m.declaration.type)}::read_xdr(r)?,"
                      end.join("\n")}
                    })
                })
            }
        }

        impl WriteXdr for #{name struct} {
            #[cfg(feature = "alloc")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<()> {
                w.with_limited_depth(|w| {
                    #{struct.members.map do |m|
                      "self.#{field_name(m)}.write_xdr(w)?;"
                    end.join("\n")}
                    Ok(())
                })
            }
        }
        EOS
        out.break
      end

      def render_enum(out, enum)
        out.puts "// enum"
        out.puts "#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
        out.puts %{#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]}
        if @options[:rust_types_custom_str_impl].include?(name enum)
          out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr))]}
        else
          out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]}
        end
        if !@options[:rust_types_custom_jsonschema_impl].include?(name enum)
          out.puts %{#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]}
        end
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
        impl #{name enum} {
            pub const VARIANTS: [#{name enum}; #{enum.members.count}] = [ #{enum.members.map { |m| "#{name enum}::#{name m}," }.join("\n")} ];
            pub const VARIANTS_STR: [&'static str; #{enum.members.count}] = [ #{enum.members.map { |m| "\"#{name m}\"," }.join("\n")} ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    #{enum.members.map do |m|
                      "Self::#{name m} => \"#{name m}\","
                    end.join("\n")}
                }
            }

            #[must_use]
            pub const fn variants() -> [#{name enum}; #{enum.members.count}] {
                Self::VARIANTS
            }
        }

        impl Name for #{name enum} {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<#{name enum}> for #{name enum} {
            fn variants() -> slice::Iter<'static, #{name enum}> {
                Self::VARIANTS.iter()
            }
        }

        impl Enum for #{name enum} {}

        impl fmt::Display for #{name enum} {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                f.write_str(self.name())
            }
        }

        impl TryFrom<i32> for #{name enum} {
            type Error = Error;

            fn try_from(i: i32) -> Result<Self> {
                let e = match i {
                    #{enum.members.map do |m| "#{m.value} => #{name enum}::#{name m}," end.join("\n")}
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<#{name enum}> for i32 {
            #[must_use]
            fn from(e: #{name enum}) -> Self {
                e as Self
            }
        }

        impl ReadXdr for #{name enum} {
            #[cfg(feature = "alloc")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self> {
                r.with_limited_depth(|r| {
                    let e = i32::read_xdr(r)?;
                    let v: Self = e.try_into()?;
                    Ok(v)
                })
            }
        }

        impl WriteXdr for #{name enum} {
            #[cfg(feature = "alloc")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<()> {
                w.with_limited_depth(|w| {
                    let i: i32 = (*self).into();
                    i.write_xdr(w)
                })
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
        if union.default_arm.present?
          $stderr.puts "warn: union #{name union} includes default arms and default arms are not supported in the rust generator"
        end
        discriminant_type = reference(nil, union.discriminant.type)
        discriminant_type_builtin = is_builtin_type(union.discriminant.type) || (is_builtin_type(union.discriminant.type.resolved_type.type) if union.discriminant.type.respond_to?(:resolved_type) && AST::Definitions::Typedef === union.discriminant.type.resolved_type)
        out.puts "// union with discriminant #{discriminant_type}"
        out.puts "#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]"
        out.puts %{#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]}
        if @options[:rust_types_custom_str_impl].include?(name union)
          out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr))]}
        else
          out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]}
        end
        if !@options[:rust_types_custom_jsonschema_impl].include?(name union)
          out.puts %{#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]}
        end
        out.puts "#[allow(clippy::large_enum_variant)]"
        out.puts "pub enum #{name union} {"
        union_case_count = 0
        out.indent do
          union_cases(union) do |case_name, arm|
            union_case_count += 1
            out.puts arm.void? ? "#{case_name}#{"(())" unless arm.void?}," : "#{case_name}(#{reference(union, arm.type)}),"
          end
        end
        out.puts '}'
        out.puts ""
        out.puts <<-EOS.strip_heredoc
        impl #{name union} {
            pub const VARIANTS: [#{discriminant_type}; #{union_case_count}] = [
                #{union_cases(union) do |case_name, arm, value|
                  value.nil?                ? "#{discriminant_type}::#{case_name}," :
                  discriminant_type_builtin ? "#{value}," :
                                              "#{discriminant_type}(#{value}),"
                end.join("\n")}
            ];
            pub const VARIANTS_STR: [&'static str; #{union_case_count}] = [
                #{union_cases(union) do |case_name, arm, value|
                  "\"#{case_name}\","
                end.join("\n")}
            ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    #{union_cases(union) do |case_name, arm|
                      "Self::#{case_name}#{"(_)" unless arm.void?} => \"#{case_name}\","
                    end.join("\n")}
                }
            }

            #[must_use]
            pub const fn discriminant(&self) -> #{discriminant_type} {
                #[allow(clippy::match_same_arms)]
                match self {
                    #{union_cases(union) do |case_name, arm, value|
                      "Self::#{case_name}#{"(_)" unless arm.void?} => #{
                        value.nil?                ? "#{discriminant_type}::#{case_name}" :
                        discriminant_type_builtin ? "#{value}" :
                                                    "#{discriminant_type}(#{value})"
                      },"
                    end.join("\n")}
                }
            }

            #[must_use]
            pub const fn variants() -> [#{discriminant_type}; #{union_case_count}] {
                Self::VARIANTS
            }
        }

        impl Name for #{name union} {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Discriminant<#{discriminant_type}> for #{name union} {
            #[must_use]
            fn discriminant(&self) -> #{discriminant_type} {
                Self::discriminant(self)
            }
        }

        impl Variants<#{discriminant_type}> for #{name union} {
            fn variants() -> slice::Iter<'static, #{discriminant_type}> {
                Self::VARIANTS.iter()
            }
        }

        impl Union<#{discriminant_type}> for #{name union} {}

        impl ReadXdr for #{name union} {
            #[cfg(feature = "alloc")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self> {
                r.with_limited_depth(|r| {
                    let dv: #{discriminant_type} = <#{discriminant_type} as ReadXdr>::read_xdr(r)?;
                    #[allow(clippy::match_same_arms, clippy::match_wildcard_for_single_variants)]
                    let v = match dv {
                        #{union_cases(union) do |case_name, arm, value|
                          "#{
                            value.nil? ? "#{discriminant_type}::#{case_name}" : "#{value}"
                          } => #{
                            arm.void? ? "Self::#{case_name}" : "Self::#{case_name}(#{reference_to_call(union, arm.type)}::read_xdr(r)?)"
                          },"
                        end.join("\n")}
                        #[allow(unreachable_patterns)]
                        _ => return Err(Error::Invalid),
                    };
                    Ok(v)
                })
            }
        }

        impl WriteXdr for #{name union} {
            #[cfg(feature = "alloc")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<()> {
                w.with_limited_depth(|w| {
                    self.discriminant().write_xdr(w)?;
                    #[allow(clippy::match_same_arms)]
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
                })
            }
        }
        EOS
        out.break
      end

      def render_typedef(out, typedef)
        if is_builtin_type(typedef.type)
          out.puts "pub type #{name typedef} = #{reference(typedef, typedef.type)};"
        else
          out.puts "#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]"
          out.puts %{#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]}
          out.puts "#[derive(Default)]" if is_var_array_type(typedef.type)
          if is_fixed_array_opaque(typedef.type) || @options[:rust_types_custom_str_impl].include?(name typedef)
            out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr))]}
          else
            out.puts %{#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]}
          end
          if !is_fixed_array_opaque(typedef.type) && !@options[:rust_types_custom_jsonschema_impl].include?(name typedef)
            out.puts %{#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]}
          end
          if !is_fixed_array_opaque(typedef.type)
            out.puts "#[derive(Debug)]"
          end
          out.puts "pub struct #{name typedef}(pub #{reference(typedef, typedef.type)});"
          out.puts ""
          if is_fixed_array_opaque(typedef.type)
          out.puts <<-EOS.strip_heredoc
          impl core::fmt::Debug for #{name typedef} {
            fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
                let v = &self.0;
                write!(f, "#{name typedef}(")?;
                for b in v {
                    write!(f, "{b:02x}")?;
                }
                write!(f, ")")?;
                Ok(())
            }
          }
          EOS
          end
          if is_fixed_array_opaque(typedef.type) && !@options[:rust_types_custom_str_impl].include?(name typedef)
          out.puts <<-EOS.strip_heredoc
          impl core::fmt::Display for #{name typedef} {
            fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
                let v = &self.0;
                for b in v {
                    write!(f, "{b:02x}")?;
                }
                Ok(())
            }
          }

          #[cfg(feature = "alloc")]
          impl core::str::FromStr for #{name typedef} {
            type Err = Error;
            fn from_str(s: &str) -> core::result::Result<Self, Self::Err> {
                hex::decode(s).map_err(|_| Error::InvalidHex)?.try_into()
            }
          }
          EOS
          end
          if is_fixed_array_opaque(typedef.type) && !@options[:rust_types_custom_jsonschema_impl].include?(name typedef)
          out.puts <<-EOS.strip_heredoc
          #[cfg(feature = "schemars")]
          impl schemars::JsonSchema for #{name typedef} {
              fn schema_name() -> String {
                  "#{name typedef}".to_string()
              }

              fn is_referenceable() -> bool {
                  false
              }

              fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
                  let schema = String::json_schema(gen);
                  if let schemars::schema::Schema::Object(mut schema) = schema {
                      schema.extensions.insert(
                          "contentEncoding".to_owned(),
                          serde_json::Value::String("hex".to_string()),
                      );
                      schema.extensions.insert(
                          "contentMediaType".to_owned(),
                          serde_json::Value::String("application/binary".to_string()),
                      );
                      let string = *schema.string.unwrap_or_default().clone();
                      schema.string = Some(Box::new(schemars::schema::StringValidation {
                          max_length: #{typedef.type.size}_u32.checked_mul(2).map(Some).unwrap_or_default(),
                          min_length: #{typedef.type.size}_u32.checked_mul(2).map(Some).unwrap_or_default(),
                          ..string
                      }));
                      schema.into()
                  } else {
                      schema
                  }
              }
          }
          EOS
          end
          out.puts <<-EOS.strip_heredoc
          impl From<#{name typedef}> for #{reference(typedef, typedef.type)} {
              #[must_use]
              fn from(x: #{name typedef}) -> Self {
                  x.0
              }
          }

          impl From<#{reference(typedef, typedef.type)}> for #{name typedef} {
              #[must_use]
              fn from(x: #{reference(typedef, typedef.type)}) -> Self {
                  #{name typedef}(x)
              }
          }

          impl AsRef<#{reference(typedef, typedef.type)}> for #{name typedef} {
              #[must_use]
              fn as_ref(&self) -> &#{reference(typedef, typedef.type)} {
                  &self.0
              }
          }

          impl ReadXdr for #{name typedef} {
              #[cfg(feature = "alloc")]
              fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self> {
                  r.with_limited_depth(|r| {
                      let i = #{reference_to_call(typedef, typedef.type)}::read_xdr(r)?;
                      let v = #{name typedef}(i);
                      Ok(v)
                  })
              }
          }

          impl WriteXdr for #{name typedef} {
              #[cfg(feature = "alloc")]
              fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<()> {
                  w.with_limited_depth(|w|{ self.0.write_xdr(w) })
              }
          }
          EOS
          if is_fixed_array_type(typedef.type)
            out.break
            out.puts <<-EOS.strip_heredoc
            impl #{name typedef} {
                #[must_use]
                pub fn as_slice(&self) -> &[#{element_type_for_vec(typedef.type)}] {
                    &self.0
                }
            }

            #[cfg(feature = "alloc")]
            impl TryFrom<Vec<#{element_type_for_vec(typedef.type)}>> for #{name typedef} {
                type Error = Error;
                fn try_from(x: Vec<#{element_type_for_vec(typedef.type)}>) -> Result<Self> {
                    x.as_slice().try_into()
                }
            }

            #[cfg(feature = "alloc")]
            impl TryFrom<&Vec<#{element_type_for_vec(typedef.type)}>> for #{name typedef} {
                type Error = Error;
                fn try_from(x: &Vec<#{element_type_for_vec(typedef.type)}>) -> Result<Self> {
                    x.as_slice().try_into()
                }
            }

            impl TryFrom<&[#{element_type_for_vec(typedef.type)}]> for #{name typedef} {
                type Error = Error;
                fn try_from(x: &[#{element_type_for_vec(typedef.type)}]) -> Result<Self> {
                    Ok(#{name typedef}(x.try_into()?))
                }
            }

            impl AsRef<[#{element_type_for_vec(typedef.type)}]> for #{name typedef} {
                #[must_use]
                fn as_ref(&self) -> &[#{element_type_for_vec(typedef.type)}] {
                    &self.0
                }
            }
            EOS
          end
          if is_var_array_type(typedef.type)
            out.break
            out.puts <<-EOS.strip_heredoc
            impl Deref for #{name typedef} {
              type Target = #{reference(typedef, typedef.type)};
              fn deref(&self) -> &Self::Target {
                  &self.0
              }
            }

            impl From<#{name typedef}> for Vec<#{element_type_for_vec(typedef.type)}> {
                #[must_use]
                fn from(x: #{name typedef}) -> Self {
                    x.0.0
                }
            }

            impl TryFrom<Vec<#{element_type_for_vec(typedef.type)}>> for #{name typedef} {
                type Error = Error;
                fn try_from(x: Vec<#{element_type_for_vec(typedef.type)}>) -> Result<Self> {
                    Ok(#{name typedef}(x.try_into()?))
                }
            }

            #[cfg(feature = "alloc")]
            impl TryFrom<&Vec<#{element_type_for_vec(typedef.type)}>> for #{name typedef} {
                type Error = Error;
                fn try_from(x: &Vec<#{element_type_for_vec(typedef.type)}>) -> Result<Self> {
                    Ok(#{name typedef}(x.try_into()?))
                }
            }

            impl AsRef<Vec<#{element_type_for_vec(typedef.type)}>> for #{name typedef} {
                #[must_use]
                fn as_ref(&self) -> &Vec<#{element_type_for_vec(typedef.type)}> {
                    &self.0.0
                }
            }

            impl AsRef<[#{element_type_for_vec(typedef.type)}]> for #{name typedef} {
                #[cfg(feature = "alloc")]
                #[must_use]
                fn as_ref(&self) -> &[#{element_type_for_vec(typedef.type)}] {
                    &self.0.0
                }
                #[cfg(not(feature = "alloc"))]
                #[must_use]
                fn as_ref(&self) -> &[#{element_type_for_vec(typedef.type)}] {
                    self.0.0
                }
            }
            EOS
          end
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
          'bool'
        when AST::Typespecs::Double
          $stderr.puts "warn: rust generator has not implemented f64 support"
          'f64'
        when AST::Typespecs::Float
          $stderr.puts "warn: rust generator has not implemented f64 support"
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
            "StringM::<#{type.decl.resolved_size}>"
          else
            "StringM"
          end
        when AST::Typespecs::Opaque
          if type.fixed?
            "[u8; #{type.size}]"
          elsif !type.decl.resolved_size.nil?
            "BytesM::<#{type.decl.resolved_size}>"
          else
            "BytesM"
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

      def array_size(type)
        _, size = type.array_size
        size = name @top.find_definition(size) if is_named
        size
      end

      def reference(parent, type)
        base_ref = base_reference type

        parent_name = name(parent) if parent
        cyclic = is_type_in_type_field_types(base_ref, parent_name)

        case type.sub_type
        when :simple
          if cyclic
            "Box<#{base_ref}>"
          else
            base_ref
          end
        when :optional
          if cyclic
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
            "VecM::<#{base_ref}>"
          end
        else
          raise "Unknown sub_type: #{type.sub_type}"
        end
      end

      def element_type_for_vec(type)
        case type
        when AST::Typespecs::String
          "u8"
        when AST::Typespecs::Opaque
          "u8"
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          if type.respond_to?(:resolved_type) && AST::Definitions::Typedef === type.resolved_type && is_builtin_type(type.resolved_type.type)
            base_reference(type.resolved_type.type)
          else
            name type
          end
        else
          raise "Unknown element type for vec: #{type.class.name}, #{type.class.ancestors}"
        end
      end

      def base_reference_to_call(type)
        case type
        when AST::Typespecs::String
          if !type.decl.resolved_size.nil?
            "StringM::<#{type.decl.resolved_size}>"
          else
            "StringM"
          end
        when AST::Typespecs::Opaque
          if type.fixed?
            "[u8; #{type.size}]"
          elsif !type.decl.resolved_size.nil?
            "BytesM::<#{type.decl.resolved_size}>"
          else
            "BytesM"
          end
        when AST::Typespecs::Simple, AST::Definitions::Base, AST::Concerns::NestedDefinition
          if type.respond_to?(:resolved_type) && AST::Definitions::Typedef === type.resolved_type && is_builtin_type(type.resolved_type.type)
            base_reference_to_call(type.resolved_type.type)
          else
            base_reference(type)
          end
        else
          base_reference(type)
        end
      end

      def reference_to_call(parent, type)
        base_ref = base_reference_to_call(type)

        parent_name = name(parent) if parent
        cyclic = is_type_in_type_field_types(base_ref, parent_name)

        ref = case type.sub_type
        when :simple
          if cyclic
            "Box<#{base_ref}>"
          else
            base_ref
          end
        when :optional
          if cyclic
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
            "VecM::<#{base_ref}>"
          end
        else
          raise "Unknown sub_type: #{type.sub_type}"
        end

        if ref.starts_with?("[") && ref.ends_with?("]")
          "<#{ref}>"
        elsif ref.starts_with?("Box<") && ref.ends_with?(">")
          "Box::#{ref.delete_prefix("Box")}"
        else
          ref
        end
      end

      def name(named)
        parent = name named.parent_defn if named.is_a?(AST::Concerns::NestedDefinition)

        base = if named.respond_to?(:name_short)
          named.name_short
        elsif named.respond_to?(:name)
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
