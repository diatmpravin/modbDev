# Methods of Group handling the grading of various values on vehicles
# in a group or it's subgroups
class Group < ActiveRecord::Base

  module Grade
    VALUE_ATTRIBUTES = []

    PASS = 0
    WARN = 1
    FAIL = 2
  end

  # Given an attribute in key and a current value,
  # grade the value according to rules that have been given to this Group
  #
  # TODO Actually implement this
  def grade(key, value)
    r = rand(100)
    if r < 15
      Grade::FAIL
    elsif r < 30
      Grade::WARN
    else 
      Grade::PASS
    end
  end

end
