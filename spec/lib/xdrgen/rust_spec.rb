require 'spec_helper'

describe Xdrgen::Generators::Rust do
  generator_fixture_paths.each do |path|
    it "can generate #{File.basename path}" do
      c = generate path, ""
    end

    it "can generate #{File.basename path} with custom str impls" do
      c = generate path, "_custom_str_impls", {
        rust_types_custom_str_impl: [
          "Foo",
          "TestArray",
          "Color2",
          "UnionKey",
          "MyUnion",
          "HasOptions",
          "MyStruct",
          "LotsOfMyStructs",
        ],
      }
    end
  end

  def generate(path, output_sub_path, options = {rust_types_custom_str_impl: []})
    compilation = Xdrgen::Compilation.new(
        [path],
        output_dir: "#{SPEC_ROOT}/output/generator_spec_rust#{output_sub_path}/#{File.basename path}",
        language:   "rust",
        namespace:  "MyXDR",
        options:    options,
      )
    compilation.compile
    compilation
  end
end
