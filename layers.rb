require 'entities'
require 'graphs'

class Layer
  def initialize(name)
    @name = name
    @entities = []
    @graph = nil
    @path_graph = nil
  end
  
  def <<(value)
    @entities << value
    @graph = nil # invalidate graph
  end
                
  def name
    @name
  end
    
  def entities
    @entities
  end
  
  def inspect
    "Layer(#{@entities.size} entities)"
  end
  
  def graph
    @graph ||= AdjacencyGraph.new(@entities)
  end
  
  def path_graph
    @path_graph ||= PathGraph.new(@entities)    
  end
  
  def merge(other_layer)
    other_layer.entities.each do |entity|
      self << entity
    end
  end
  
end