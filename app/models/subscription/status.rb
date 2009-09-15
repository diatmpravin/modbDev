class Subscription < ActiveRecord::Base
  include AASM

  aasm_initial_state :needs_setup
  aasm_column :status

  aasm_state :needs_setup
  aasm_state :active
  aasm_state :failed
  aasm_state :failed_again
  aasm_state :cancelled

  aasm_event :charge_failed do
    transitions :from => :needs_setup, :to => :needs_setup
    transitions :from => :active, :to => :failed, :on_transition => :do_failed
    transitions :from => :failed, :to => :failed_again, :on_transition => :do_failed_again
    transitions :from => :failed_again, :to => :cancelled, :on_transition => :do_cancelled
    transitions :from => :cancelled, :to => :cancelled
  end

  aasm_event :charge_success do
    transitions :to => :active, 
      :from => [:active, :failed, :failed_again, :cancelled], 
      :on_transition => :do_active

    transitions :from => :needs_setup, :to => :active, :on_transition => :do_setup
  end

  STATUS_TEXT = {
    "active" => "Active",
    "failed" => "Last Charge Failed",
    "failed_again" => "Last Charge Failed - Pending Cancellation",
    "cancelled" => "<span class='red'>Inactive</span>"
  } unless defined?(STATUS_TEXT)

  def status_text
    STATUS_TEXT[self.status]
  end

  private

  # The following methods are called on state transitions.
  # We do custom handling of the subscription object when
  # these events fire.

  def do_setup
    BillingMailer.deliver_new_subscription(self)
  end

  def do_failed
    self.cancellation_date = Date.today + 2.days
    BillingMailer.deliver_charge_unsuccessful(self)
  end

  def do_failed_again
    BillingMailer.deliver_charge_unsuccessful(self)
  end

  def do_cancelled
    BillingMailer.deliver_charge_unsuccessful(self)
  end

  def do_active
    self.cancellation_date = nil
    BillingMailer.deliver_charge_successful(self)
  end

end
