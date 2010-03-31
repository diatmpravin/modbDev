# Methods of DeviceGroup handling the grading of various values on vehicles
# in a group or it's subgroups
class DeviceGroup < ActiveRecord::Base

  module Grade
    VALID_PARAMS = [
      :mpg,
      :speed_events,
      :geofence_events,
      :idle_events,
      :aggressive_events,
      :after_hours_events,
      :first_start,
      :last_stop
    ]
     # Mark which parameters are time entries
     TIME_PARAMS = {
       :first_start => true,
       :last_stop => true
     }

    # Mark which parameters should be handled
    # in the reverse order, aka bigger is good, 
    # smaller is bad
    PARAM_REVERSED = {
      :mpg => true,
      :last_stop => true
    }

    PASS = 0
    WARN = 1
    FAIL = 2
  end

  class GradeProxy
    def initialize(group)
      @group = group
      @group.grading ||= {}
    end

    DeviceGroup::Grade::VALID_PARAMS.each do |param|
      define_method(param) do
        @group.grading[param] ||= {}
      end

      define_method("#{param}=") do |val|
        @group.grading[param] = val
      end
    end
  end

  def grade_proxy
    GradeProxy.new(self)
  end

  # Given an attribute in key and a current value,
  # grade the value according to rules that have been given to this Group.
  def grade(key, value)
    return Grade::PASS unless value

    # default value for should cover this, though
    if self.grading.nil?
      self.update_attribute(:grading, {})
    end

    equation = self.grading[key]

    if (equation.nil? or equation[:fail] == "")
      return Grade::PASS
    end

    #return Grade::PASS unless equation 
    #return Grade::PASS unless equation[:fail] != ""

    if Grade::PARAM_REVERSED[key]

      if value >= equation[:pass].to_i
        Grade::PASS
      elsif value < equation[:pass].to_i && value > equation[:fail].to_i
        Grade::WARN
      else
        Grade::FAIL
      end

    else

      if value > equation[:fail].to_i
        Grade::FAIL
      elsif value <= equation[:fail].to_i && value > equation[:pass].to_i
        Grade::WARN
      else
        Grade::PASS
      end

    end
  end

end
