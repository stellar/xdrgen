require 'spec_helper'

describe Xdrgen::Generators do
  it "can accept a custom generator to generate" do
    expect(TestGenerator).to receive(:new).with(
      an_instance_of(Xdrgen::AST::Top),
      an_instance_of(Xdrgen::Output),
      "namespace",
      { option: true },
    ).and_call_original
    expect_any_instance_of(TestGenerator).to receive(:generate).with(no_args)
    Xdrgen::Compilation.new(
      generator_fixture_paths,
      output_dir: "output_dir/",
      generator: TestGenerator,
      namespace: "namespace",
      options: { option: true }
    ).compile
  end
end

class TestGenerator < Xdrgen::Generators::Base
  def generate; end
end
