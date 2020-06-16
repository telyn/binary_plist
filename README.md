# BinaryPlistParser

A parser for BinaryPList files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'binary_plist_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install binary_plist_parser

## Usage

```ruby
require "binary_plist/parser"

obj = { "hello" => "world", "u_ok?" => true, "nums" => [1,2,3] }

bpl = BinaryPList.dump(obj)
puts BinaryPList.load(bpl)

# { "hello" => "world", "u_ok?" => true, "nums" => [1,2,3] }
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run
`rspec` to run the tests.

To install this gem onto your local machine, ran `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/binary_plist_parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
