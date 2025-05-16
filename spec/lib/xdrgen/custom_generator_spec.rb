require 'spec_helper'

describe Xdrgen::Generators do
  generator_fixture_paths.each do |path|
    it "can accept a custom generator to generate #{File.basename path}" do
      expect(TestGenerator).to receive(:new).with(
        an_instance_of(Xdrgen::AST::Top),
        an_instance_of(Xdrgen::Output),
        "namespace",
        {},
      ).and_call_original
      expect_any_instance_of(TestGenerator).to receive(:generate).with(no_args)
      Xdrgen::Compilation.new(
        [path],
        output_dir: "#{SPEC_ROOT}/output/custom_generator_spec/#{File.basename path}",
        generator: TestGenerator,
        namespace: "namespace",
      ).compile
    end
  end
end

class TestGenerator < Xdrgen::Generators::Base
  def generate; end
end
