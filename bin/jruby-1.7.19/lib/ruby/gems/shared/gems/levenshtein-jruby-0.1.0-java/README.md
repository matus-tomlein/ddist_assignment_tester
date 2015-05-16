# Levenshtein (JRuby)
[![Build Status](https://travis-ci.org/dwbutler/levenshtein-jruby.png)](https://travis-ci.org/dwbutler/levenshtein-jruby)

Calculates the Levenshtein distance between two strings. Uses the
[Apache Commons](http://commons.apache.org/proper/commons-lang/apidocs/org/apache/commons/lang3/StringUtils.html#getLevenshteinDistance\(java.lang.CharSequence, java.lang.CharSequence\)) Java implementation.

## Installation

Add this line to your application's Gemfile:

    gem 'levenshtein-jruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install levenshtein-jruby

## Usage

```ruby
require 'levenshtein'

# Basic usage
Levenshtein.distance("string1", "string2") # => 1

# With threshold
Levenshtein.distance("string1", "String2", 2) # => 2
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
