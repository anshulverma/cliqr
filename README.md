# cliqr

[![Build](http://img.shields.io/travis-ci/anshulverma/cliqr.svg?style=flat-square)](https://travis-ci.org/anshulverma/cliqr)
[![Coverage](http://img.shields.io/codeclimate/coverage/github/anshulverma/cliqr.svg?style=flat-square)](https://codeclimate.com/github/anshulverma/cliqr)
[![Quality](http://img.shields.io/codeclimate/github/anshulverma/cliqr.svg?style=flat-square)](https://codeclimate.com/github/anshulverma/cliqr)
[![Dependencies](http://img.shields.io/gemnasium/anshulverma/cliqr.svg?style=flat-square)](https://gemnasium.com/anshulverma/cliqr)
[![Downloads](http://img.shields.io/gem/dtv/cliqr.svg?style=flat-square)](https://rubygems.org/gems/cliqr)
[![Version](http://img.shields.io/gem/v/cliqr.svg?style=flat-square)](https://rubygems.org/gems/cliqr)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [cliqr](#cliqr)
    - [Summary](#summary)
    - [Examples](#examples)
        - [Simple CLI app with basename and description](#simple-cli-app-with-basename-and-description)
    - [Installation](#installation)
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
