class Vector
  def initialize(x,y,z)
    @x = x
    @y = y
    @z = z
  end
  
  def magnitude
    Math::sqrt(@x**2 + @y**2 + @z**2)
  end
  
  def inspect
    "Vector(#{@x},#{@y},#{@z})"
  end
  
  def x
    @x
  end
  
  def x=(value)
    @x=value
  end
  
  def y
    @y
  end
  
  def y=(value)
    @y=value
  end
  
  def z
    @z
  end
  
  def z=(value)
    @z=value
  end
  
  # Compares two vectors for aproximate equality
  def =~(value)
    return true if value == self
    return false unless value.is_a?(Vector)
    return false if (@x-value.x).abs > 0.00000001
    return false if (@y-value.y).abs > 0.00000001
    return false if (@z-value.z).abs > 0.00000001
    true
  end
  
  def distance(other)
    Math::sqrt((@x-other.x)**2+(@y-other.y)**2+(@z-other.z)**2)
  end
  
  def nearest(point, vectors)
    distance = 999999999999.0
    nearest = nil
    vectors.each do |vector|
      d = vector.distance(self)
      if d<distance
        distance=d
        nearest = vector
      end
    end
    nearest
  end

  def farthest(vectors)
    distance = 0
    farthest = nil
    vectors.each do |vector|
      d = vector.distance(self)
      if d>distance
        distance=d
        farthest = vector
      end
    end
    farthest
  end
  
end