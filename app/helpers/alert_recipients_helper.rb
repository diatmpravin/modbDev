module AlertRecipientsHelper
  def alert_options_for(geofence)
    '<option value="">Select Alert Recipient</option>' +
    options_from_collection_for_select(current_account.alert_recipients.for(geofence), :id, :display_string)
  end
end