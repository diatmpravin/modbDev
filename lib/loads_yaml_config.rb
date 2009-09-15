# Given a YAML file located in /config and an environment name, make any
# configuration settings available as the given symbol.
#
#   class Example
#     include LoadsYamlConfig
#     loads :my_config, 'my_config.yml', 'development'
#   end
#
module LoadsYamlConfig
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end
  
  module ClassMethods
    def loads_yaml_config(symbol, yaml_file, env = Rails.env)
      metaclass = class << self; self; end
      metaclass.send :define_method, symbol do
        begin
          return class_variable_get("@@#{symbol}")
        rescue NameError
          val = YAML.load_file(
            File.join(RAILS_ROOT, 'config', yaml_file)
          ).with_indifferent_access
          if val[env]
            class_variable_set("@@#{symbol}", val[env])
          else
            raise "#{yaml_file}: '#{env}' not defined"
          end
        end
      end
    end
  end
  
end # LoadsYamlConfig