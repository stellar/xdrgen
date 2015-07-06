guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')        { "spec" }
  watch(%r{^spec/support/(.+)\.rb$})  { "spec" }

  watch(%r{^lib/(.+)\.treetop$})                { "spec/lib/xdrgen/parser_spec.rb" }
  watch(%r{^lib/(.+)_nodes\.rb$})               { "spec/lib/xdrgen/parser_spec.rb" }
  watch(%r{^lib/xdrgen/generators/(.+)\.rb$})   { "spec/lib/xdrgen/generator_spec.rb" }
  watch(%r{^spec/fixtures/parser/(.+)\.x$})     { "spec/lib/xdrgen/parser_spec.rb" }
  watch(%r{^spec/fixtures/generator/(.+)\.x$})  { "spec/lib/xdrgen/generator_spec.rb" }
end
