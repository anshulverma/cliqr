# encoding: utf-8

require 'delegate'

module Cliqr
  # Used to separate all dsl methods in a separate block, thus allowing
  # separation of concerns between non-dsl methods with dsl methods which
  # improves maintainability.
  module DSL
    # Entry point for invoking dsl methods
    #
    # @param [Hash] args Arguments to be used to build the DSL instance
    #
    # @param [Function] block The block to evaluate the DSL
    #
    # @return [Cliqr::DSL]
    def build(*args, &block)
      base = new(*args)
      if block_given?
        delegator = DSLDelegator.new(base)
        delegator.instance_eval(&block)
      end
      base.finalize
      base
    end

    # Delegates all DSL methods to the base class. Can be used to keep DSL
    # methods separate from non-dsl methods. All implementing subclasses will
    # have to implement a set_config method as described below
    #
    #     class MyDSLClass
    #       extends Cliqr::DSL
    #
    #       def set_config(name, value, &block)
    #         # handle config value for attribute "name"
    #       end
    #     end
    #
    # This will be invoked as:
    #
    #     MyDSLClass.build do
    #       attribute 'some-value'
    #     end
    class DSLDelegator < SimpleDelegator
      # All dsl methods are handled dynamically by this method_missing block.
      # Essentially, this method acts as a proxy for subclass' set_config
      # method.
      def method_missing(name, *args, &block)
        __getobj__.set_config name, args[0], &block
      end
    end
  end
end
