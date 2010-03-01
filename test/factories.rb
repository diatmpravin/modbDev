Factory.sequence :imei_number do |n|
  "%015d" % [n]
end

Factory.sequence :sim_number do |n|
  "%020d" % [n]
end

Factory.define :tracker do |tracker|
  tracker.imei_number { Factory.next(:imei_number) }
  tracker.sim_number { Factory.next(:sim_number) }
  tracker.account { Account.find_by_number(10001) }
end

Factory.define :device do |device|
  device.name "Device"
  device.account { Account.find_by_number(10001) }
  device.association :tracker
end

Factory.define :point do |point|
  point.association :device
  point.association :leg
  point.occurred_at Time.now
  point.miles 0
end

Factory.define :trip do |trip|
  trip.association :device
end

Factory.define :leg do |leg|
  leg.association :trip
end
