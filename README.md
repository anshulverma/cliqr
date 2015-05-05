# cliqr

[![Build Status](https://travis-ci.org/anshulverma/cliqr.svg?branch=master)](https://travis-ci.org/anshulverma/cliqr)
[![Gem Version](https://badge.fury.io/rb/cliqr.svg)](http://badge.fury.io/rb/cliqr)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [Cliqr](#cliqr)
    - [Summary](#summary)
    - [Installation](#installation)
    - [Usage](#usage)
    - [Contributing](#contributing)

<!-- markdown-toc end -->


## Summary

`cliqr` is a lightweight framework and DSL to easily build a command
line application. Features include:

- Command Routing
- DSL for simple interface definition
- Usage info generation
- Error handling

## Examples

The DSL provides several helper methods to build interfaces of different
styles. Here are some examples.

### Simple CLI app with basename and description

Here is a simple hello-world example for using Cliqr.

``` ruby
cli = Cliqr.interface do
  basename 'my-command'
end
puts cli.usage
```

This should print

```
USAGE: my-command
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cliqr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cliqr

## Contributing

1. Fork it ( https://github.com/anshulverma/cliqr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
