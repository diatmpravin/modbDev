class Jasper
  attr_accessor :error, :error_detail, :response
  
  RATE_PLANS = [
    'Default RP'
  ]
  
  def get_sim_info(sim)
    @error = @error_detail = @response = nil
    handle_response(JasperApi.get_terminal_details(sim))
  end

  def activate(sim)
    @error = @error_detail = @response = nil
    handle_response(JasperApi.activate_terminal(sim))
  end

  def deactivate(sim)
    @error = @error_detail = @response = nil
    handle_response(JasperApi.deactivate_terminal(sim))
  end
  
  def set_rate_plan(sim, plan)
    @error = @error_detail = @response = nil
    handle_response(JasperApi.set_rate_plan(sim, plan))
  end
  
  def successful?
    !!@response
  end
  
  def to_xml(options = {})
    @response.to_xml({:root => 'sim'}.merge(options))
  end
  
  protected
  def handle_response(response)
    if response[:error]
      @error = response[:error]
      @error_detail = response[:error_detail]
      @response = false
    else
      if response.is_a?(Hash)
        @response = response
      else
        @response = true
      end
    end
  end
end