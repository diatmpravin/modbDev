module PhoneFinder::Carriers::PhonesHelper
  def formatted_phone_name(phone, carrier)
    if phone.aliases.nil? || phone.aliases.empty?
      phone.name
    elsif (a = phone.aliases.select {|a| a.carrier_id == carrier.id}).any?
      "#{phone.name} (#{a[0].name})"
    elsif (a = phone.aliases.select {|a| a.carrier_id == 0}).any?
      "#{phone.name} (#{a[0].name})"
    else
      phone.name
    end
  end
end
