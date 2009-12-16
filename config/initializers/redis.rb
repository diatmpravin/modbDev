class Redis
  def self.config
    @config ||= YAML.load_file(File.join(Rails.root, 'config', 'redis.yml')).with_indifferent_access[Rails.env]
  end
  
  def self.build(options = {})
    Redis.new(self.config.merge(options))
  end
end
