class DefaultEventOccurredAt < ActiveRecord::Migration
  def self.up
    Event.all(:conditions => "occurred_at IS NULL").each do |e|
      e.update_attribute(:occurred_at, e.created_at)
    end
  end

  def self.down
  end
end