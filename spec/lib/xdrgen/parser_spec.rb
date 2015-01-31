require 'spec_helper'

describe Xdrgen::Parser, ".parse" do
  
  it "can parse all of the fixtures" do
    results = fixtures.map do |path, content|
                [path, parseable?(content)]
              end

    failed = results.select{|r| !r.last}

    if failed.any?
      failed_paths = failed.map(&:first)
      indented     = failed_paths.map{|p| "\t#{p}"}

      fail "couldn't parse:\n#{indented.join("\n")}"
    end
  end

  def parseable?(content)
    begin
      subject.parse(content)
      true
    rescue Xdrgen::ParseError
      false
    end
  end
end