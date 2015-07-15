Here is a list of all releases with a description of what went in for
that release along with features, improvements and bug fixes. Click on a
item in this nested table for further details.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [2.1.0 / 2015-07-15](#210--2015-07-15)
    - [Features](#features)
        - [Make use of `readline` lib for shell mode.](#make-use-of-readline-lib-for-shell-mode)
    - [Bugfix](#bugfix)
        - [Handle spaces in command arguments](#handle-spaces-in-command-arguments)
    - [Minor improvements](#minor-improvements)
        - [Use shortened URl for gif in README](#use-shortened-url-for-gif-in-readme)
- [2.0.0 / 2015-07-09](#200--2015-07-09)
    - [Features](#features)
        - [Event handling](#event-handling)
            - [Default events for shell](#default-events-for-shell)
        - [Colors](#colors)
        - [Customizable banner and prompt for shell](#customizable-banner-and-prompt-for-shell)
    - [Backward incompatible changes](#backward-incompatible-changes)
    - [Improvements](#improvements)
        - [Partial templated](#partial-templated)
        - [Improve default prompt](#improve-default-prompt)
        - [Screen capture in README](#screen-capture-in-readme)
    - [Minor changes](#minor-changes)
        - [Shorten the quickstart example](#shorten-the-quickstart-example)
        - [Re-organize code and move specs around](#re-organize-code-and-move-specs-around)
        - [Multi OS testing suprted added to CI](#multi-os-testing-suprted-added-to-ci)
    - [Bugfixes](#bugfixes)
        - [Fix examples to follow new breaking shell config change](#fix-examples-to-follow-new-breaking-shell-config-change)
        - [Do not put allow arguments in shell config](#do-not-put-allow-arguments-in-shell-config)
- [1.2.0 / 2015-06-18](#120--2015-06-18)
    - [Features](#features)
        - [Nested actions](#nested-actions)
        - [Ability to operate on arguments](#ability-to-operate-on-arguments)
        - [Anonymous Proc for command handling and argument operation](#anonymous-proc-for-command-handling-and-argument-operation)
        - [Default value for options](#default-value-for-options)
        - [Default command actions](#default-command-actions)
            - [Help](#help)
            - [Version](#version)
            - [Shell](#shell)
        - [Forward command from one handler to another](#forward-command-from-one-handler-to-another)
    - [Improvements](#improvements)
        - [Use name instead of basename](#use-name-instead-of-basename)
        - [Reorganize tests](#reorganize-tests)
        - [Can get value in operator by calling `value`](#can-get-value-in-operator-by-calling-value)
        - [Run anonymous command handler in the the context of `CommandContext`](#run-anonymous-command-handler-in-the-the-context-of-commandcontext)
        - [Call `help` action by default](#call-help-action-by-default)
        - [Add Examples for using `Cliqr`](#add-examples-for-using-cliqr)
        - [Update `README` to make it more relevant](#update-readme-to-make-it-more-relevant)
    - [Bug-fixes](#bug-fixes)
        - [Fix option parsing for option with symbolic name](#fix-option-parsing-for-option-with-symbolic-name)
        - [Handle errors gracefully](#handle-errors-gracefully)
        - [Include template in gem](#include-template-in-gem)
        - [Fix shell in shell issue](#fix-shell-in-shell-issue)
- [1.1.0 / 2015-06-05](#110--2015-06-05)
    - [Features](#features)
        - [Support for arbitrary arguments in a command](#support-for-arbitrary-arguments-in-a-command)
    - [Minor Improvements](#minor-improvements)
        - [Improve readme example](#improve-readme-example)
        - [Reorganize config validation logic](#reorganize-config-validation-logic)
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


2.1.0 / 2015-07-15
==================

## Features

### Make use of `readline` lib for shell mode.

This gives us a huge advantage by supporting command history and meta
character handling out of the box.

Some tweaks will come in smaller patches soon.

## Bugfix

### Handle spaces in command arguments

Reported by @AlgyTaylor.

We were not able to parse a argument as a continuous value if it had a
space in it. This was fixed by using `shellwords`.

## Minor improvements

### Use shortened URl for gif in README

This allows a little bit of analytics for the trafic to the git repo.

2.0.0 / 2015-07-09
==================

Another big release!

## Features

### Event handling

Added ability to invoke arbitiary events and define handlers to handle
certain kind of events.

Here is an example:
``` ruby
Cliqr.interface do
  name 'my-command'
  on :bar do |event, ch, num|
    puts 'invoked event in base'
    puts "option = #{opt}"
    puts "ch = #{ch}; num = #{num}"
  end

  action :my_action do
    on :bar do |event, ch, num|
      puts 'invoked event in action'
      puts "option = #{opt}"
      puts "ch = #{ch}; num = #{num}"
    end

    handler do
      invoke :bar, 'a', 10
    end

    option :opt
  end
end
```
Upon execution:
``` bash
$ my-command my_action --opt qwerty
invoked event in action
option = qwerty
ch = a; num = 10
invoked event in base
option = qwerty
ch = a; num = 10
```

Events can be chained as above example shows.

#### Default events for shell

When a shell starts a `shell_start` event is invoked. Upon exit, a
`shell_exit` event is invoked.

### Colors

Enabled colors in command handlers and usage output. Just call a
function with the name of the color you want. Colors can also be
disabled.

### Customizable banner and prompt for shell

The shell action now allows you to configure the banner displayed in the
beginning and define a method to build the prompt.

## Backward incompatible changes

The shell action can only be used in the base command config.

## Improvements

### Partial templated

Templates are reused to build help doc by incorporation of partial erb
templating.

### Improve default prompt

Count is shown in the default prompt.

### Screen capture in README

A screen capture of the example is added to readme now.

## Minor changes

### Shorten the quickstart example

### Re-organize code and move specs around

### Multi OS testing suprted added to CI

CI now runs all specs for Linux and OSX

## Bugfixes

### Fix examples to follow new breaking shell config change

### Do not put allow arguments in shell config

1.2.0 / 2015-06-18
==================

This is a pretty loaded release in terms of features, improvements and
bug-fixes. Here is a detailed list.

## Features

### Nested actions

Every command is a action and in this release, we add support for
building nested command structure.

For example:

``` bash
$ vagrant up --provision
```

This command has:

- Base-command: vagrant
  - Sub action: up
    - Option: provision

### Ability to operate on arguments

You can now specify a operator that can pre-process the option arguments
and, if needed, do validation as well.

### Anonymous Proc for command handling and argument operation

No need to define a separate class to handle a command or operate on
arguments.

### Default value for options

Options can now have a default value. In some cases this is derived from
option type attribute.

### Default command actions

Several default actions were added to a command.

#### Help

Help is added by default to every action. This includes a help action
and option.

#### Version

If specified, a version action and boolean option is added to the action.

#### Shell

Shell is enabled by default if there are any sub-actions for a command.

### Forward command from one handler to another

A new method `forward` can be called with arguments that are parsed and
executed again.

## Improvements

### Use name instead of basename

The only reason for this was to make things simple and consistent.

### Reorganize tests

Divide tests by functionality. In some cases group them together.

### Can get value in operator by calling `value`

### Run anonymous command handler in the the context of `CommandContext`

### Call `help` action by default

If you call a command without specifying any arguments, its help action
will be invoked (assuming it is enabled).

### Add Examples for using `Cliqr`

Examples for some popular commands like `vagrant` and `hbase` along with
some custom commands were added.

### Update `README` to make it more relevant

## Bug-fixes

### Fix option parsing for option with symbolic name

### Handle errors gracefully

Errors do not kill the running script anymore and they do not show stack
trace.

### Include template in gem

### Fix shell in shell issue

It should be not allowed to run a shell within another shell.

1.1.0 / 2015-06-05
==================

A small, yet a very important release. In this release we add support
for arbitrary arguments.

## Features

### Support for arbitrary arguments in a command

For the first time you can invoke a command with non-option arguments.

## Minor Improvements

### Improve readme example

### Reorganize config validation logic

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
