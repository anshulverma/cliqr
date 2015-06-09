# encoding: utf-8

# A argument operator that splits the value by ','
class CSVArgumentOperator < Cliqr.operator
  def operate(value)
    value.split(',')
  end
end
