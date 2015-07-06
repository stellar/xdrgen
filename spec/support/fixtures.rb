module FixtureProvider
  extend ActiveSupport::Concern

  included do |base|
    let(:fixture_paths) do
      self.class.fixture_paths
    end

    let(:fixtures) do
      fixture_paths.
        map{|p| [p, IO.read(p)]}.
        to_h
    end
  end

  class_methods do
    def fixture_paths
      Dir["#{__dir__}/../fixtures/**/*.x"]
    end
  end
end

RSpec::configure do |c|
  c.include FixtureProvider
end
