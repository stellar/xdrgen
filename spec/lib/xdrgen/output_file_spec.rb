require 'spec_helper'

describe Xdrgen::OutputFile, "#balance_after" do
  let(:output_path){ "#{SPEC_ROOT}/output/balanced.txt"}
  let(:unbalanced) do
    <<-EOS.strip_heredoc
    attribute :hello, XDR::UnsignedInt
    attribute :i_am_a_long_field, XDR::UnsignedInt
    attribute :s, XDR::UnsignedInt
    EOS
  end

  let(:actual){ IO.read(output_path) }
  let(:balanced) do
    <<-EOS.strip_heredoc
    attribute :hello,             XDR::UnsignedInt
    attribute :i_am_a_long_field, XDR::UnsignedInt
    attribute :s,                 XDR::UnsignedInt
    EOS
  end

  subject{ Xdrgen::OutputFile.new(output_path) }

  after(:each){ FileUtils.rm output_path }

  it "balanaces the input string on each line after splitting on the provided regex" do
    subject.balance_after /.+?,/ do
      subject.puts unbalanced
    end
    subject.close
    expect(actual).to eq(balanced)
  end
end
