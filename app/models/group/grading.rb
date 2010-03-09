# Methods of Group handling the grading of various values on vehicles
# in a group or it's subgroups
class Group < ActiveRecord::Base

  module Grade
    PASS = 0
    WARN = 1
    FAIL = 2
  end

  # Given an attribute in key and a current value,
  # grade the value according to rules that have been given to this Group.
  def grade(key, value, days = 1)
    test = days > 1 ? value / days : value

    if self.grading.nil? 
      self.update_attribute(:grading, {})
    end

    equation = self.grading[key]

    return Grade::PASS unless equation

    if test > equation[:fail]
      Grade::FAIL
    elsif test < equation[:fail] && test > equation[:pass]
      Grade::WARN
    else 
      Grade::PASS
    end
  end

end
