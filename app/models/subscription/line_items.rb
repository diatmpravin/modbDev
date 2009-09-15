LineItem = Struct.new(:description, :amount) unless defined?(LineItem)

class Subscription < ActiveRecord::Base

  serialize :line_items, Array

  # Line items are per-tracker break-downs of
  # a customer's subscription.
  def line_items
    items = self.account.devices.active.map do |d| 
      LineItem.new("Vehicle: #{d.name}", self.pay_plan.amount)
    end
    items += self[:line_items] if (self[:line_items] || []).any?
    items
  end

  # Subtotal is the direct amount of all line items
  def subtotal
    self.line_items.inject(BigDecimal.new("0")) { |memo, li| memo + li.amount }
  end

  # Get taxes for the total
  def taxes
    got = TaxesService::Taxes.calculate_for(
      self.subtotal, self.state, self.zip)
      
    BigDecimal.new(got[:state])
  end

  # Take taxes and subtotal and get a final total
  def total
    subtotal + taxes
  end

  # Save a line item in the database for this subscription
  # to be used later when running a recurring payment
  def add_line_item(li)
    self[:line_items] ||= []
    self[:line_items] << li
    self.save
  end

end
