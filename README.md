# Xdrgen

`xdrgen` is a code generator that takes XDR IDL files (`.x` files) as specified
in [RFC 4506](http://tools.ietf.org/html/rfc4506.html) and provides the AST to
code generators. It is intended to be used as a library with custom generators.

`xdrgen` requires ruby 3.1 to 3.3 to run.

## Status

Xdrgen is a relatively stable library and major changes have not been made to
it for sometime.

Aside from the test fixtures in [spec/fixtures](spec/fixtures), the only .x
files that have been tested with it are the .x files used for the [Stellar
protocol](https://github.com/stellar/stellar-xdr).

> [!NOTE]
> **Generators are no longer included in this repository.** If you're building a
> code generator, use xdrgen as a library (see below). Generators that were
> previously included (Python, Rust) have been slowly moved out to other
> repositories, usually close to the Stellar XDR libraries they generated. For
> any that were not moved but deleted (C#, Elixir, Ruby), they can be found in
> the repository history at commit
> [2efacde](https://github.com/stellar/xdrgen/tree/2efacde612445d97e0548131ed699e8130bdeb7b)
> if they need to be used with the binary, otherwise any new maintenance of
> those code generators should ideally happen using xdrgen as a library.

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

The CLI still has the following built-in generators:

- javascript
- golang
