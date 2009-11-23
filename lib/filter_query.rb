class FilterQuery

  # Given a query string, parse it out into an appropriate Hash
  # structure for Model.search to work properly.
  def self.parse(query)
    filter = {:full => query}
    key = :query

    query.split("\s").each do |word|
      filter[key] ||= []
      if word =~ /(.*):$/
        key = $1.to_sym
      else
        filter[key] << word
      end
    end

    filter.each_key do |k|
      filter[k] = filter[k].join(" ") if filter[k].is_a?(Array)
    end

    filter
  end

end
