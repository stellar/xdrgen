require 'spec_helper'

describe Xdrgen::Generators do
  languages = %w(ruby javascript go java)

  fixture_paths.each do |path|
    languages.each do |lang|

      it "can generate #{File.basename path} in #{lang}" do
        generate lang, [path]
      end

    end
  end

  def generate(language, files)
    compilation = Xdrgen::Compilation.new(
        files,
        output_dir: "tmp/generator_spec_#{language}",
        language:   language,
        namespace:  ""
      )
    compilation.compile
  end
end
