# Methods of Group handling the grading of various values on vehicles
# in a group or it's subgroups
class Group < ActiveRecord::Base

  module Grade
    VALID_PARAMS = [:miles, 
      :duration,
      :speed_events,
      :geofence_events,
      :idle_events,
      :aggressive_events,
      :after_hours_events,
      :first_start_time,
      :last_end_time
    ]

    PASS = 0
    WARN = 1
    FAIL = 2
  end

  class GradeProxy
    def initialize(group)
      @group = group
    end

    Group::Grade::VALID_PARAMS.each do |param|
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
  def grade(key, value, days = 1)
    test = days > 1 ? value / days : value

    if self.grading.nil? 
      self.update_attribute(:grading, {})
    end

    equation = self.grading[key]

    return Grade::PASS unless equation

    if test > equation[:fail].to_i
      Grade::FAIL
    elsif test < equation[:fail].to_i && test > equation[:pass].to_i
      Grade::WARN
    else 
      Grade::PASS
    end
  end

end
