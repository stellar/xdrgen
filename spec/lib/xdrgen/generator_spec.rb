require 'spec_helper'

describe Xdrgen::Generators do
  languages = %w(ruby javascript go java)

  generator_fixture_paths.each do |path|
    languages.each do |lang|

      it "can generate #{File.basename path} in #{lang}" do
        generate lang, path
      end

    end
  end

  def generate(language, path)
    compilation = Xdrgen::Compilation.new(
        [path],
        output_dir: "tmp/generator_spec_#{language}/#{File.basename path}",
        language:   language,
        namespace:  "MyXDR"
      )
    compilation.compile
  end
end
