class Redis
  def self.config
    @config ||= YAML.load_file(Rails.root.join('config', 'redis.yml')).with_indifferent_access[Rails.env]
  end
  
  def self.build(options = {})
    Redis.new(Redis.config.merge(options))
  end
end
