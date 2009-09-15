class Subscription < ActiveRecord::Base

  belongs_to :next_pay_plan, :foreign_key => "next_pay_plan_id", :class_name => "PayPlan"

  # Change the subscription's pay plan. This doesn't actually
  # change the plan immediately, but marks the subscription
  # as requiring a change-over at next bill date.
  # If the change id given is the same as the current pay plan,
  # then we clear out the flag.
  def change_pay_plan_to(id)
    self.next_pay_plan_id = 
      if self.pay_plan_id == id.to_i
         nil
      else
        id.to_i
      end
      
    self.save
  end



end
