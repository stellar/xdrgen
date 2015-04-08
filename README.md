# Xdrgen

[![Build Status](https://travis-ci.org/stellar/xdrgen.svg)](https://travis-ci.org/stellar/xdrgen)
[![Code Climate](https://codeclimate.com/github/stellar/xdrgen/badges/gpa.svg)](https://codeclimate.com/github/stellar/xdrgen)

`xdrgen` is a code generator that takes XDR IDL files (`.x` files) as specfified 
in [RFC 4506](http://tools.ietf.org/html/rfc4506.html) and spits code out in 
various languages.

## Status

Xdrgen is a very early project.  Aside from the test fixtures in 
[spec/fixtures](spec/fixtures), the only .x files that have been thrown at it
are the .x files used for the 
[stellar-core project](https://github.com/stellar/stellar-core).

Xdrgen presently supports three output languages:  ruby, javacript, and golang:

- ruby: complete support
- javascript: complete but only lightly exercised
- golang: buggy and experimental

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
  language: :ruby
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
