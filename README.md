# Xdrgen

[![Build Status](https://travis-ci.org/stellar/xdrgen.svg)](https://travis-ci.org/stellar/xdrgen)
[![Code Climate](https://codeclimate.com/github/stellar/xdrgen/badges/gpa.svg)](https://codeclimate.com/github/stellar/xdrgen)

`xdrgen` is a code generator that takes XDR IDL files (`.x` files) as specified
in [RFC 4506](http://tools.ietf.org/html/rfc4506.html) and spits code out in
various languages.

`xdrgen` requires ruby 2.1 or later to run.

## Status

Xdrgen is a very early project.  Aside from the test fixtures in
[spec/fixtures](spec/fixtures), the only .x files that have been thrown at it
are the .x files used for the
[stellar-core project](https://github.com/stellar/stellar-core).

Xdrgen presently supports these output languages:  ruby, javacript, java,
golang, and elixir:

- ruby: complete support
- javascript: complete support
- java: complete support
- golang: currently using a fork of go-xdr, but has complete support
- rust: support is experimental. Default arms and floats are not supported.
- elixir: support is experimental as the SDK is in early development. Generated
  code requires [:exdr](https://github.com/revelrylabs/exdr) in your deps
- C#: complete support
  
Testing is _very_ sparse, but will improve over time.

## Usage as a binary

Xdrgen is a rubygem, compatible with ruby 2.1 or higher

    $ gem install xdrgen

The command line:

`xdrgen [-o OUTPUT_DIR] [-l LANGUAGE] [-n NAMESPACE] [INPUT_FILES ...]`

## Usage as a library

Add this line to your application's Gemfile:

```ruby
gem 'xdrgen'
```

And then execute:

    $ bundle

Example usage:

```ruby
require 'xdrgen'

# create a compilation object, specifying your options

c = Xdrgen::Compilation.new(
  ["MyProgram.x"],
  output_dir:"src/generated",
  language: :ruby,
  namespace: "MyProgram::XDR"
)

# then run compile

c.compile

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/xdrgen/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
