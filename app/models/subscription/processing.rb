class Subscription < ActiveRecord::Base

  MINIMUM_CHARGE_AMOUNT = BigDecimal.new("5.00") unless defined?(MINIMUM_CHARGE_AMOUNT)

  # This concerns handles all the logic behind charging
  # and working with user subscriptions.

  # Run the whole billing process on this subscription
  # for the passed in date.
  #
  # See BillingProcessor for more information
  #
  def process(run_date = Date.today)
    return true if self.next_bill_date > run_date

    clear_marked_devices

    # If clear_marked_devices above has removed all
    # devices on the account, then we're done here!
    return true if self.account.devices.count == 0

    update_pay_plan

    returning( make_charge ) do |result|
      update_next_bill_date if result
    end
  end

  # If next_pay_plan_id is set, change our current pay plan
  # to that plan
  def update_pay_plan
    if next_pay_plan_id
      self.pay_plan_id = next_pay_plan_id
      self.next_pay_plan_id = nil
      self.save
      self.reload
    end
  end

  # Create a charge for this subscription
  def make_charge
    payment = new_payment
    payment.payment_type = Payment::TYPE_STATEMENT
    payment.save

    returning( payment.process ) do |result|
      if result
        charge_success!
      else
        charge_failed!
      end
    end
  end

  # Update to the next bill date
  def update_next_bill_date
    months_since_first_bill = 
      (self.next_bill_date.year - self.first_bill_date.year) * 12 + 
      (self.next_bill_date.month - self.first_bill_date.month)

    period = self.pay_plan.period

    months_since_first_bill = 0 if months_since_first_bill < 0

    self.next_bill_date = 
      self.first_bill_date >> (months_since_first_bill + period)
    self.save
  end

  # Charge a proration amount for a new vehicle
  def charge_proration
    amount = self.prorated_device_amount
    li = LineItem.new("Proration for new vehicle", amount)

    if amount > MINIMUM_CHARGE_AMOUNT
      payment = self.payments.build :line_items => [li]
      payment.payment_type = Payment::TYPE_ONE_TIME
      payment.save

      payment.process
    else
      self.add_line_item li
      true
    end
  end

  protected

  def clear_marked_devices
    self.account.devices.find(:all, :conditions => {:to_be_deleted => true}).each do |d|
      d.destroy
    end
  end

end
