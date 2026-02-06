# Xdrgen

`xdrgen` is a code generator that takes XDR IDL files (`.x` files) as specified
in [RFC 4506](http://tools.ietf.org/html/rfc4506.html) and provides the AST to
code generators. It can be used as a library with custom generators, or for
legacy purposes as a CLI with any of the built-in legacy generators.

`xdrgen` requires ruby 3.1 to 3.3 to run.

## Status

Xdrgen is an early project but also relatively stable and major changes have
not been made to the library for sometime.

Aside from the test fixtures in [spec/fixtures](spec/fixtures), the only .x
files that have been tested with it are the .x files used for the [Stellar
protocol](https://github.com/stellar/stellar-xdr).

If you're building a new code generator, the preferred way to provide a code
generator to xdrgen is to use it as a library. See below for examples for how
to do so.

## Usage as a library

Add this line to your application's Gemfile:

```ruby
gem 'xdrgen'
```

And then execute:

```
$ bundle
```

Example usage:

```ruby
require 'xdrgen'

class Generator < Xdrgen::Generators::Base
  def generate
    out = @output.open("#{@namespace}.rs")
    # Use @top to access the top of the AST.
    # Use @options to access any options passed via the compile.
    # Use out.puts to write code.
  end
end

Xdrgen::Compilation.new(
  ["MyProgram.x"],
  output_dir:"src/generated",
  generator: Generator,
  namespace: "MyProgram::XDR",
  options: { }, # any option your generator needs
).compile
```

## Usage as a binary (legacy)

Xdrgen is a rubygem, compatible with ruby 2.1 or higher

    $ gem install xdrgen

The command line:

`xdrgen [-o OUTPUT_DIR] [-l LANGUAGE] [-n NAMESPACE] [INPUT_FILES ...]`

Xdrgen has support for built-in generators via the CLI's `-l` option, but they
are not maintained, not tested, and are preserved for legacy usage.

- ruby: complete support
- javascript: complete support
- golang: currently using a fork of go-xdr, but has complete support
- elixir: support is experimental as the SDK is in early development. Generated
  code requires [:exdr](https://github.com/revelrylabs/exdr) in your deps
- C#: complete support

## Contributing new generators / languages

Instead of contributing new generators to this repository, use xdrgen as a
library and maintain the generator independently where you can test and
maintain it.
