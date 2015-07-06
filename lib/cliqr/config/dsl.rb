# encoding: utf-8

require 'delegate'

module Cliqr
  module Config
    # Used to separate all dsl methods in a separate block, thus allowing
    # separation of concerns between non-dsl methods with dsl methods which
    # improves maintainability.
    #
    # @api private
    module DSL
      # If a class includes this module, we add a few useful methods to that class
      #
      # @see http://www.ruby-doc.org/core/Module.html#method-i-included
      #
      # @return [Object]
      def self.included(base)
        base.class_eval do
          def self.inherited(base)
            transfer_validations(base)
            DSL.included(base)
          end

          def self.transfer_validations(base)
            base.validations.merge(validations)
          end

          # Entry point for invoking dsl methods
          #
          # @param [Hash] args Arguments to be used to build the DSL instance
          #
          # @param [Function] block The block to evaluate the DSL
          #
          # @return [Cliqr::DSL]
          def self.build(*args, &block)
            base = new(*args)
            if block_given?
              delegator = DSLDelegator.new(base)
              delegator.instance_eval(&block)
            end
            base.finalize
            base
          end
        end
      end

      # Delegates all DSL methods to the base class. Can be used to keep DSL
      # methods separate from non-dsl methods. All implementing subclasses will
      # have to implement a set_config method as described below
      #
      #     class MyDSLClass
      #       include Cliqr::Config::DSL
      #
      #       attr_accessor :attribute
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
        # All dsl methods are handled dynamically by proxying through #set_config
        #
        # @param [Symbol] name Name of the method
        # @param [Array] args Method arguments
        # @param [Function] block A function to evaluate in the context of the method's arguments
        #
        # @return [Object] The return value of the proxied method
        def method_missing(name, *args, &block)
          __getobj__.set_config(name, args[0], *args[1..-1], &block)
        end
      end
    end
  end
end
