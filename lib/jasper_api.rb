# belongs elsewhere
gem 'soap4r', '>= 1.5.8'

require 'soap/wsdlDriver'
require 'soap/header/handler'

module JasperApi
  ENV = 'api'  # Replace with 'api' to use the production environment.
  LICENSE_KEY = '842944c4-0929-475f-b8ae-1e655f9659cc'
  USERNAME = 'mobdapi'
  PASSWORD = 'Ahw8IvieXo2Rahda'

  #WSDL_URL = 'http://' + ENV + '.jaspersystems.com/ws/schema/Terminal.wsdl'
  WSDL_URL = 'lib/jasper/Terminal.wsdl' # this is the production wsdl
  
  # Helper class for SOAP headers.
  class Header < SOAP::Header::Handler
    @@WSSE_URI = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    @@PASSWORD_TYPE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'
    
    @@HEADER = XSD::QName.new(@@WSSE_URI, 'Security')
    def initialize(username, password)
      super(@@HEADER)
      @username, @password = username, password
    end

    def on_outbound
      usernameTokenEl = SOAP::SOAPElement.new(XSD::QName.new(@@WSSE_URI, 'UsernameToken'))
      usernameTokenEl.add(SOAP::SOAPElement.new(XSD::QName.new(@@WSSE_URI, 'Username'), @username))
      passwordEl = SOAP::SOAPElement.new(XSD::QName.new(@@WSSE_URI, 'Password'), @password)
      passwordEl.extraattr['Type'] = @@PASSWORD_TYPE
      usernameTokenEl.add(passwordEl)
      securityEl = SOAP::SOAPElement.new(@@HEADER)
      securityEl.add(usernameTokenEl)
      SOAP::SOAPHeaderItem.new(securityEl)
    end
  end
  
  def self.activate_terminal(sim_id)
    change_terminal_state(sim_id, 'ACTIVATED_NAME')
  end
  
  def self.deactivate_terminal(sim_id)
    change_terminal_state(sim_id, 'DEACTIVATED_NAME')
  end
  
  def self.set_rate_plan(sim_id, rate_plan)
    svc = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    svc.headerhandler << Header.new(USERNAME, PASSWORD)

    # Uncomment the following line to view the XML request/response.
    # svc.wiredump_dev = STDERR

    svc.EditTerminal(:messageId => '', :version => '',
        :licenseKey => LICENSE_KEY,
        :iccid => sim_id,
        :changeType => 4,
        :targetValue => rate_plan)
  rescue SOAP::FaultError => ex
    {:error => ex.faultstring.text, :error_detail => ex.detail.error}
  rescue => ex
    {:error => 1, :error_detail => ex.to_s}
  end

  def self.get_terminal_details(sim_id)
    svc = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    svc.headerhandler << Header.new(USERNAME, PASSWORD)

    # Uncomment the following line to view the XML request/response.
    svc.wiredump_dev = STDERR

    result = svc.GetTerminalDetails(:messageId => '', :version => '',
        :licenseKey => LICENSE_KEY,
        :iccids => {:iccid => [ sim_id ]})

    term = result['terminals']['terminal']
    
    {
      :status => term['status'],
      :sim => term['iccid'],
      :rate_plan => term['ratePlan'],
      :usage => term['monthToDateUsage'],
      
      # Is there an easier way to get attributes?
      :msisdn => term.__xmlattr[XSD::QName.new(nil, 'msisdn')]
    }
  rescue SOAP::FaultError => ex
    {:error => ex.faultstring.text}
    #:error_detail => ex.detail}
  rescue => ex
    {:error => 1, :error_detail => ex.to_s}
  end
  
  private
  def self.change_terminal_state(sim_id, new_state)
    svc = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    svc.headerhandler << Header.new(USERNAME, PASSWORD)

    # Uncomment the following line to view the XML request/response.
    # svc.wiredump_dev = STDERR

    svc.EditTerminal(:messageId => '', :version => '',
        :licenseKey => LICENSE_KEY,
        :iccid => sim_id,
        :changeType => 3,
        :targetValue => new_state)
  rescue SOAP::FaultError => ex
    {:error => ex.faultstring.text, :error_detail => ex.detail.error}
  rescue => ex
    {:error => 1, :error_detail => ex.to_s} 
  end
end