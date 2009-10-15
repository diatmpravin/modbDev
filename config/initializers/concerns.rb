module Concerns
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end
end

ActiveRecord::Base.send(:extend, Concerns)
