# Xdrgen

`xdrgen` is a code generator that take XDR IDL files (`.x` files) and outputs,
at present, ruby code that is complient with the ruby-xdr helper library

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xdrgen'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xdrgen

## Usage as a binary

The command line is simple:

`xdrgen -o OUTPUT_DIR INPUT_FILE`

## Usage as a library

```ruby
require 'xdrgen'

# create a compilation object, specifying your input file
# and output directory

c = Xdrgen::Compilation.new("MyProgram.x", "src/generated")

# then run compile

c.compile

```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/xdrgen/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
