require 'fundamentals'

class GeometricEntity
  def self.class_for_type(value)
    case value
    when :line
      Line
    when :arc
      Arc
    when :circle
      Circle
    when :text
      Text
    when :point
      Point
    end
  end
end

class Point < GeometricEntity
  def initialize(options)
    @at = options[:at]
  end
  
  def from 
    @at
  end  
  
  def to
    @at
  end
  
  def center
    @at
  end  
end

class Line < GeometricEntity
  def initialize(options)
    @from = Vector.new(*options[:from]) || Vector.new(0.0,0.0,0.0)
    @to = Vector.new(*options[:to]) || Vector.new(0.0,0.0,0.0)
  end
  
  def from
    @from
  end
  
  def to
    @to
  end

  def inspect
    "Line{:from => #{@from.inspect}, :to => #{@to.inspect}}"
  end
end

class Arc < GeometricEntity
  def initialize(options)
    @center = Vector.new(*options[:center]) || Vector.new(0.0,0.0,0.0)
    @radius = options[:radius] || 0.0
    @from_radians = options[:from_radians]
    @to_radians = options[:to_radians]
    @from_radians ||= options[:from_degrees]/180.0*Math::PI
    @to_radians ||= options[:to_degrees]/180.0*Math::PI
  end
  
  def center
    @center
  end
  
  def radius
    @radius
  end
  
  def from_radians
    @from_radians
  end
  
  def to_radians
    @to_radians
  end
  
  def from
    Vector.new(Math::sin(@from_radians)*@radius+@center.x,
      Math::cos(@from_radians)*@radius+@center.y,
      @center.z)
  end

  def to
    Vector.new(Math::sin(@to_radians)*@radius+@center.x,
      Math::cos(@to_radians)*@radius+@center.y,
      @center.z)
  end

  def inspect
    "Arc{:center => #{@center.inspect}, :radius => #{@radius}, :from_radians => #{@from_radians}, :to_radians => #{@to_radians}}"
  end
end

class Circle < GeometricEntity
  def initialize(options)
    @center = Vector.new(*options[:center]) || Vector.new(0.0,0.0,0.0)
    @radius = options[:radius] || 0.0
  end

  def center
    @center
  end
  
  def radius
    @radius
  end

  def from
    Vector.new(@center.x-@radius,
      @center.y,
      @center.z)
  end 
  
  def to
    Vector.new(@center.x-@radius,
      @center.y,
      @center.z)
  end
  
  def inspect
    "Circle{:center => #{@center.inspect}, :radius => #{@radius}}"
  end
end

class Text < GeometricEntity
  def initialize(options)
    @position = Vector.new(*options[:position]) || Vector.new(0.0,0.0,0.0)
    @string = options[:string]
    @linetype = options[:linetype]
  end
  
  def from
    @position
  end
  
  def to
    @position
  end
end