require 'spec_helper'

describe Xdrgen::Parser, ".parse" do

  it "can parse all of the fixtures" do
    results = parser_fixture_paths.map do |path|
                content = IO.read(path)
                {path:path}.merge parse(content)
              end

    failed = results.select{|r| !r[:success]}

    if failed.any?
      failures = failed.map{|r| "\t#{r[:path]} failed on line #{r[:failure_line]}"}
      fail "couldn't parse:\n#{failures.join("\n")}"
    end
  end

  def parse(content)
    begin
      subject.parse(content)
      {success: true}
    rescue Xdrgen::ParseError
      {success: false, failure_line: subject.failure_line}
    end
  end
end
