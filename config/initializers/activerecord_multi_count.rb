# Until ActiveRecord Calculations allow multiple group by parameters, this
# will need to fill the gap. Abuses two rare characters (0x07 and 0x09) to form
# a combined "group by" field, then breaks it apart after ActiveRecord does its
# magic.
#
#   self.multi_count(:group => [:symptom_id, :treatment_id])
#   [[["138", "1018"], 187], [["138", "427"], 373], [["6", "1018"], 197], [["6", "427"], 393]]
class ActiveRecord::Base
  def self.multi_count(opts = {})
    unless opts[:group].nil?
      opts[:group] = opts[:group].map {|g| "COALESCE(#{g}, CHAR(7))"}.join(",")
      opts[:group] = "CONCAT_WS(CHAR(9),#{opts[:group]})"
    end
    
    self.count(opts).map { |key,value| [key.split("\t").map {|k| k == "\x07" ? nil : k}, value] }
  end
end
