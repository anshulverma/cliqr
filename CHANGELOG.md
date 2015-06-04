Here is a list of all releases with a description of what went in for
that release along with features, improvements and bug fixes. Click on a
item in this nested table for further details.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [1.0.0 / 2015-06-04](#100--2015-06-04)
    - [Features](#features)
        - [Support for option types](#support-for-option-types)
    - [Improvements](#improvements)
        - [Generic CLI config validator implementation](#generic-cli-config-validator-implementation)
    - [Minor Improvements](#minor-improvements)
        - [Reduce the number of error types](#reduce-the-number-of-error-types)
        - [Maintain example in readme](#maintain-example-in-readme)
    - [Bug-fixes](#bug-fixes)
        - [It should be optional to include options in a command](#it-should-be-optional-to-include-options-in-a-command)
- [0.1.0 / 2015-05-29](#010--2015-05-29)
    - [Features](#features)
        - [First pass at building ability to parse command line arguments](#first-pass-at-building-ability-to-parse-command-line-arguments)
        - [Validations of command line arguments](#validations-of-command-line-arguments)
    - [Minor improvements](#minor-improvements)
        - [Organize the specs properly](#organize-the-specs-properly)
        - [Add more description in README](#add-more-description-in-readme)
    - [Bug-fixes](#bug-fixes)
- [0.0.4 / 2015-05-11](#004--2015-05-11)
    - [Features](#features)
        - [Documentation coverage](#documentation-coverage)
        - [Command options](#command-options)
        - [Command router](#command-router)
        - [Command usage building](#command-usage-building)
    - [Minor improvements](#minor-improvements)
        - [Improve README example](#improve-readme-example)
        - [Improve README metrics](#improve-readme-metrics)
    - [Bug fixes](#bug-fixes)
        - [Minor style fix in rake tasks](#minor-style-fix-in-rake-tasks)
        - [Make sure specs don't execute twice](#make-sure-specs-dont-execute-twice)
- [0.0.3 / 2015-05-08](#003--2015-05-08)
    - [Features](#features)
        - [Test coverage 100%](#test-coverage-100)
        - [Check code style](#check-code-style)
    - [Minor improvements](#minor-improvements)
        - [Detect document coverage](#detect-document-coverage)
        - [Continue to improve README](#continue-to-improve-readme)
- [0.0.2 / 2015-05-07](#002--2015-05-07)
    - [Features](#features)
        - [Ability to provide name for top level command](#ability-to-provide-name-for-top-level-command)
        - [New `rake` tasks](#new-rake-tasks)
        - [Add badges to README](#add-badges-to-readme)
        - [Enable travis CI, coveralls and code climate](#enable-travis-ci-coveralls-and-code-climate)
        - [Add usage example to README](#add-usage-example-to-readme)
    - [Minor Improvements](#minor-improvements)
        - [Separate DSL methods](#separate-dsl-methods)
    - [Bug fixes](#bug-fixes)
        - [fix rake default task](#fix-rake-default-task)
- [0.0.1 / 2015-04-29](#001--2015-04-29)
    - [Features](#features)
        - [Ability to build and publish  a gem](#ability-to-build-and-publish--a-gem)
        - [`Rake` as build system](#rake-as-build-system)
        - [Incorporate `RSpec` for unit tests](#incorporate-rspec-for-unit-tests)

<!-- markdown-toc end -->

1.0.0 / 2015-06-04
==================

Aaaaand here it is ladies and gentlemen! A major release version of
`cliqr`

The main feature that was added in this release is support for option
types. Namely: `:boolean` and `:numeric`. Along with this, a major
refactoring was done for the config validator framework to make it more
generic and easy to manage in the long run.

## Features

### Support for option types

We can now restrict option values to either a number or define a option
which is either present or not. This also requires a new and improved
option parser and validator.

## Improvements

### Generic CLI config validator implementation

The idea for this came from [https://github.com/lotus/validations/]. By
doing this we can make sure that it will be fairly easy to maintain the
validation logic and extend it in future.

## Minor Improvements

### Reduce the number of error types

This was made possible by using a generic validator. So, along with all
the custom validation code we were able to get rid of the custom error
types.

### Maintain example in readme

The example in the readme file was updated to reflect the latest changes.

## Bug-fixes

### It should be optional to include options in a command

We will be adding a restriction to allow users to mark certain options
as required in future versions.

0.1.0 / 2015-05-29
==================

Finally! A minor release!

A strong command line app needs a strong command line argument
parser. This release makes that a reality by introducing a powerful
generic command line argument parser with some validation capability as
well.

## Features

### First pass at building ability to parse command line arguments

`Cliqr` can now parse command line arguments and their values. It can work
with both short names and long names for options.

### Validations of command line arguments

A basic set of validations have also been implemented:

- The option must be defined in the command line config
- Cannot use the same option twice

## Minor improvements

### Organize the specs properly

Done by moving fixtures in separate location

### Add more description in README

Examples of new developments and remove stale text

## Bug-fixes

NONE

0.0.4 / 2015-05-11
==================

Extend the capability of CLI app framework by adding some support for
command options, routing command to a handler and improved usage
information.

## Features

### Documentation coverage

`Cliqr`'s document coverage will be mainted at 100%. This is enforced at
build step.

### Command options

Add support for defining command's options in the configuration of
command line interface.  This also prints the option in a descriptive
manner in the command's usage.

### Command router

Add ability to define a command handler and route the invocation of a
command to that handler.

### Command usage building

A `erb` template is used to build the usage information for a
command. This makes it pretty easy to extend and manipulate the usage
information.


## Minor improvements

### Improve README example

Add information about option handling, command routing and usage
building.

### Improve README metrics

Add total downloads badge for gem

## Bug fixes

### Minor style fix in rake tasks

### Make sure specs don't execute twice

0.0.3 / 2015-05-08
==================

## Features

### Test coverage 100%

Used `simplecov` to assert test coverage ot 100%

### Check code style

Use `rubocop` to test code style. This also forced a bump in ruby
version to 1.9.3 since older versions are not supported by `rubocop`.

## Minor improvements

### Detect document coverage

Add inch CI badge for this.

### Continue to improve README

Add a build section

0.0.2 / 2015-05-07
==================

Starting to develop a DSL for command line definition in this
release. We will also be extending our usage of `rake`. The `README`
file should also be kept up to date.

## Features

### Ability to provide name for top level command

This is the beginning of a DSL for interface config definition

### New `rake` tasks

Add tasks like: `cleanup`, `rdoc` and `yard`

### Add badges to README

Add badges for build and code metrics.  Also use shields.io for badge
urls

### Enable travis CI, coveralls and code climate

More metrics!!

### Add usage example to README

Since documentation is good

## Minor Improvements

### Separate DSL methods

DSL methods should be kept separate from non-DSL methods

## Bug fixes

### fix rake default task

0.0.1 / 2015-04-29
==================

This is the start of this gem. Don't expect much.

## Features

### Ability to build and publish  a gem

A gem named `cliqr` is created

### `Rake` as build system

Rake is the choice of many for building and publishing artifacts

### Incorporate `RSpec` for unit tests

From this point on, we will use rspec for unit testing
