require File.expand_path(File.dirname(__FILE__) + '/rest-client/lib/restclient')

module TaxesService

  class Taxes
    cattr_accessor :site

    # Query the taxes service for tax information related
    # to the passed in arguments. Returns a hash of:
    #
    #   :state => [state tax total]
    #   :total => [amount + state tax]
    #
    def self.calculate_for(amount, state, zip)
      got = RestClient.get "#{@@site}/taxes?state=#{state}&amount=#{amount.to_s}&zip=#{zip}"
      HashWithIndifferentAccess.new(ActiveSupport::JSON.decode(got))
    end

  end

  # Specify the URL where the taxes service is
  def self.site=(url)
    Taxes.site = url
  end


end
