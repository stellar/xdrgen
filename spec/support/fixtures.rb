module FixtureProvider
  extend ActiveSupport::Concern

  included do |base|
    let(:fixture_paths)          { self.class.fixture_paths }
    let(:parser_fixture_paths)   { self.class.parser_fixture_paths }
    let(:generator_fixture_paths){ self.class.generator_fixture_paths }
  end

  class_methods do
    def fixture_paths
      Dir["#{__dir__}/../fixtures/**/*.x"]
    end

    def parser_fixture_paths
      Dir["#{__dir__}/../fixtures/parser/**/*.x"]
    end

    def generator_fixture_paths
      Dir["#{__dir__}/../fixtures/generator/**/*.x"]
    end
  end
end

RSpec::configure do |c|
  c.include FixtureProvider
end
