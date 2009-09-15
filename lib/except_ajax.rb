module ExceptAjax
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end
  
  module ClassMethods
    def except_ajax(template_name)
      symbol = "#{template_name}_except_ajax".to_sym
      define_method symbol do
        template_name unless request.xhr?
      end
      
      protected symbol
      symbol
    end
  end
  
end # ExceptAjax