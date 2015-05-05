require 'delegate'

module Cliqr
  # Used to separate all dsl methods in a separate block, thus allowing
  # separation of concerns between non-dsl methods with dsl methods which
  # improves maintainability.
  module DSL
    # Entry point for invoking dsl methods
    #
    # @param args Arguments to be used to build the DSL instance
    #
    # @param block The block to evaluate the DSL
    #
    # @return [Cliqr::DSL]
    def build(*args, &block)
      base = new(*args)
      delegator_klass = const_get('DSLDelegator')
      delegator = delegator_klass.new(base)
      delegator.instance_eval(&block)
      base
    end

    # Delegates all DSL methods to the base class. Can be used to keep DSL
    # methods separate from non-dsl methods.
    #
    # @param block Block containing all dsl methods
    #
    # Allows separating dsl methods as:
    #
    #     class MyDSLClass
    #       extends Cliqr::DSL
    #
    #       def set_value(value)
    #         @value = value
    #       end
    #
    #       # ... other non-dsl methods ...
    #
    #       dsl do
    #         def value(value)
    #           set_value value
    #         end
    #       end
    #
    #     end
    #
    # This will be invoked as:
    #
    #    MyDSLClass.build do
    #      value 'some-value'
    #    end
    def dsl(&block)
      delegator_klass = Class.new(SimpleDelegator, &block)
      const_set('DSLDelegator', delegator_klass)
    end
  end
end
