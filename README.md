# binary_plist

A parser (and maybe someday dumper) for Apple's bplist data format

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'binary_plist-parser'
```

And then execute:

    $ bundle

## Usage


```ruby
require "binary_plist/parser"

BinaryPList::Parser::BPList00.new(IO.read("spec/support/test-data/0")).parse

# => ["Cool Idea\n7", "abandoned\n1"]  
```

You can also pass in an IO object instead of a string:

```
require "binary_plist/parser"

File.open("spec/support/test-data/0", "r") do |fh|
  BinaryPList::Parser::BPList00.new(fh).parse
end

# => ["Cool Idea\n7", "abandoned\n1"]  
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run
`rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/telyn/binary_plist.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
