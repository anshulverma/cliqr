# cliqr [![Version](http://img.shields.io/gem/v/cliqr.svg?style=flat-square)](https://rubygems.org/gems/cliqr)

[![Build](http://img.shields.io/travis-ci/anshulverma/cliqr.svg?style=flat-square)](https://travis-ci.org/anshulverma/cliqr)
[![Coverage Status](https://coveralls.io/repos/github/anshulverma/cliqr/badge.svg)](https://coveralls.io/github/anshulverma/cliqr)[![Quality](http://img.shields.io/codeclimate/github/anshulverma/cliqr.svg?style=flat-square)](https://codeclimate.com/github/anshulverma/cliqr)
[![Dependencies](http://img.shields.io/gemnasium/anshulverma/cliqr.svg?style=flat-square)](https://gemnasium.com/anshulverma/cliqr)
[![Inline docs](http://inch-ci.org/github/anshulverma/cliqr.svg?style=flat-square)](http://inch-ci.org/github/anshulverma/cliqr)
[![Downloads](http://img.shields.io/gem/dt/cliqr.svg?style=flat-square)](https://rubygems.org/gems/cliqr)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [cliqr](#cliqr)
    - [Summary](#summary)
    - [Examples](#examples)
    - [Quickstart](#quickstart)
    - [Installation](#installation)
    - [Building](#building)
    - [Contributing](#contributing)

<!-- markdown-toc end -->


## Summary

`cliqr` is a lightweight yet feature rich framework which can be used to
build a powerful command line application. It provides a easy to use DSL
to define the interface of a application. Some of the features included:

- Quick and easy method for defining CLI interface
- Command usage generation based on interface definition
- Argument parsing
- Argument validation
- Nested command actions
- Multiple command handler based on arguments
- Command routing to appropriate handler
- Inbuilt shell extension for your command

## Examples

The DSL provides several helper methods to build interfaces of different
styles. Please refer to the examples folder to find some useful tips on
how to use `cliqr`.

## Quickstart

To get things started quickly here is an example of a basic `cliqr`
based CLI application (lets call this script `greet`):

``` ruby
#!/usr/bin/env ruby

require 'cliqr'

cli = Cliqr.interface do
  name 'greet'
  description 'A "hello world" app to demonstrate cliqr.'
  version '0.0.1' # optional; adds a version action to our simple command

  # main command handler
  handler do
    puts "Hi #{name}" if name? # name is command's option defined below
    puts "Please tell me your name" unless name?
  end

  option :name do
    description 'Your name.'
  end
end

cli.execute(ARGV)
```

Here is a screen capture of this script in action:
![greet script demo](https://goo.gl/sJgxFX "Binary tree example")

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cliqr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cliqr

## Building

There are various metric with different thresholds settings that needed
to be satisfied for a successful build. Here is a list:

- `rubocop` to make sure the code style checks are maintained
- `yardstick` to measure document coverage
- `codeclimate` to make we ship quality code
- `coveralls` to measure code coverage
- `rdoc` to build and measure documentation

To run all of the above, simply run:

```bash
$ rake
```

## Contributing

1. Fork it ( https://github.com/anshulverma/cliqr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
