# TODO: Rethink this class.
class Color
  attr_accessor :color_id
  attr_accessor :hex
  attr_accessor :filename
  attr_accessor :name
  
  def initialize(color_id, hex, filename, name)
    @color_id = color_id
    @hex = hex
    @filename = filename
    @name = name
  end
  
  def ==(obj)
    obj.is_a?(Color) ? self.color_id == obj.color_id : false
  end
  
  RED = Color.new(0, 'ed8383', '/images/points/red.png', 'Red')
  ORANGE = Color.new(1, 'fecd82', '/images/points/orange.png', 'Orange')
  LIME = Color.new(2, 'cdff9b', '/images/points/lime.png', 'Lime')
  GREEN = Color.new(3, '86ec86', '/images/points/green.png', 'Green')
  LIGHT_GREEN = Color.new(4, 'a0ffa6', '/images/points/lt_green.png', 'Light Green')
  TURQUOISE = Color.new(5, '85ebf7', '/images/points/turquoise.png', 'Turquoise')
  LIGHT_BLUE = Color.new(6, '96c7fd', '/images/points/lt_blue.png', 'Light Blue')
  BLUE = Color.new(7, '8487e8', '/images/points/blue.png', 'Blue')
  PURPLE = Color.new(8, 'c786f0', '/images/points/purple.png', 'Purple')
  FUCHSIA = Color.new(9, 'fa8dc8', '/images/points/fuchsia.png', 'Fuchsia')
  
  COLORS = [
    RED,
    ORANGE,
    LIME,
    GREEN,
    LIGHT_GREEN,
    TURQUOISE,
    LIGHT_BLUE,
    BLUE,
    PURPLE,
    FUCHSIA
  ]
  
  class << self
    def find(id)
      COLORS[id]
    end 
  end
end