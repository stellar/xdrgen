require 'spec_helper'

describe Xdrgen::Compilation do
  it "errors on empty list of source paths" do
    expect {
      Xdrgen::Compilation.new(
        [], # Empty list of source paths
        output_dir: "output_dir/",
        generator: TestGenerator,
        namespace: "namespace",
        options: { option: true }
      )
    }.to raise_error(/empty list of source paths/)
  end
end

class TestGenerator < Xdrgen::Generators::Base
  def generate; end
end
