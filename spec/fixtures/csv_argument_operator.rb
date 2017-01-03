# frozen_string_literal: true
# A argument operator that splits the value by ','
class CSVArgumentOperator < Cliqr.operator
  def operate(value)
    value.split(',')
  end
end
