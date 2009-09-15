module TripsHelper
  def human_duration(duration)
    if duration < 60
      '<1 minute'
    else
      pluralize((duration / 60).to_i, 'minutes')
    end
  end
  
  def human_miles(miles)
    if miles < 1
      '<1 mile'
    else
      pluralize(miles, 'miles')
    end
  end
  
  def format_tags(tags)
    if tags.any?
      tags.map { |tag|
        tag.name
      }.join(', ')
    else
      'No tags'
    end
  end
  
  def tag_options_for(trip)
    '<option value="">Select Tag</option>' +
    options_from_collection_for_select(current_account.tags.for(trip), :id, :name)
  end
end