require 'spec_helper'

describe Xdrgen::Generators do
  languages = %w(ruby javascript go elixir)
  focus_language = "" #"go"
  focus_basename = "" #"optional.x"

  generator_fixture_paths.each do |path|
    languages.each do |lang|
      next if focus_basename.present? && File.basename(path) != focus_basename
      next if focus_language.present? && lang != focus_language

      it "can generate #{File.basename path} in #{lang}" do
        c = generate lang, path
      end

    end
  end

  def generate(language, path)
    compilation = Xdrgen::Compilation.new(
        [path],
        output_dir: "#{SPEC_ROOT}/output/generator_spec_#{language}/#{File.basename path}",
        language:   language,
        namespace:  "MyXDR",
      )
    compilation.compile
    compilation
  end
end
