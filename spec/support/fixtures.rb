module FixtureProvider
  extend ActiveSupport::Concern
  included do |base|
    let(:fixture_paths) do 
      Dir["#{__dir__}/../fixtures/**/*.x"]
    end

    let(:fixtures) do
      fixture_paths.
        map{|p| [p, IO.read(p)]}.
        to_h
    end
  end
end

RSpec::configure do |c|
  c.include FixtureProvider
end