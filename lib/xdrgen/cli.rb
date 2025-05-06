require 'slop'

module Xdrgen
  module CLI
    def self.run(args)
      args = args.dup
      opts = Slop.parse! args do
        banner 'Usage: xdrgen -o OUTPUT_DIR INPUT --language=ruby'
        on 'o', 'output=', 'The output directory'
        on 'l', 'language=', 'The output language', default: 'ruby'
        on 'n', 'namespace=', '"namespace" to generate code within (language-specific)'
        on 'rust-types-custom-str-impl=', 'Rust types that should not have str implementations generated as they will be provided via custom implementations (rust-specific)'
        on 'rust-types-custom-jsonschema-impl=', 'Rust types that should not have jsonschema implementations generated as they will be provided via custom implementations (rust-specific)'
      end

      puts "ARGS"
      puts args
      puts "OPTS"
      puts opts[:output]
      puts opts[:language]
      puts opts[:namespace]
      puts opts[:"rust-types-custom-str-impl"]
      puts opts[:"rust-types-custom-jsonschema-impl"]
      puts "DONE"
      fail(opts) if args.blank?
      fail(opts) if opts[:output].blank?

      compilation = Compilation.new(
        args,
        output_dir: opts[:output],
        language:   opts[:language].to_sym,
        namespace:  opts[:namespace],
        options:    {
          rust_types_custom_str_impl: opts[:"rust-types-custom-str-impl"]&.split(',') || [],
          rust_types_custom_jsonschema_impl: opts[:"rust-types-custom-jsonschema-impl"]&.split(',') || [],
        },
      )
      compilation.compile
    end

    def self.fail(slop, code=1)
      STDERR.puts slop
      exit(code)
    end
  end
end
