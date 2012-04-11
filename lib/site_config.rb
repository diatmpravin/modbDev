module SiteConfig
  def server_host
    case Rails.env
    when "production"
      "http://mobd.gomoshi.com"
    when "qa", "staging"
      "http://mobdqa.gomoshi.com"
    else
      "http://www.mobd.local"
    end
  end
  module_function :server_host
end