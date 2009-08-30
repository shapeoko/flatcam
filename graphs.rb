# A module to model entity-collections as graphs

require 'entities'

# Maintains a collection of vectors ensuring that each point in space is 
# represented only once
class VectorVertexSet
  def initialize
    @vertices = []
  end
  
  def vertex_for(value)
    @vertices.each do |vertex|
      return vertex if value =~ vertex
    end
    @vertices << value
    value
  end
end
     
# Represents a set of geometric entities as a graph. Each edge represents an entity,
# the vertices represent the points in space connected by the entities
class AdjacencyGraph
  def initialize(entities)     
    # A collection of vectors ensuring that the same individual vector object
    # is used to represent all references to the same point in space
    @vertex_set = VectorVertexSet.new    
    
    # The graph from the perspective of edges.
    # On the form {<edge object> => [nodes connected by the edge]}
    @edges = {}
    # The graph from the perspective of vertices
    # On the form {<vertex> => [edges connected to this vertex]}
    @vertices = {}
    entities.each do |entity|
      vertex_a = @vertex_set.vertex_for(entity.from)
      vertex_b = @vertex_set.vertex_for(entity.to)
      @edges[entity] = [vertex_a, vertex_b].uniq
      @vertices[vertex_a] ||= []
      @vertices[vertex_a] |= [entity]
      @vertices[vertex_b] ||= []
      @vertices[vertex_b] |= [entity]      
    end
  end  
  
  def entities_connected_to(vector)
    @vertices[@vertex_set.vertex_for(vector)]
  end
  
  def vertices
    @vertices.keys
  end
  
  def destination_vertex(vertex, entity)
    vertices = @edges[entity]
    return vertices[1] if vertices.length>1 && vertices[1] != vertex
    vertices[0]
  end        
  
  def inspect
    "AdjacencyGraph(#{@vertices.keys.size} vertices, #{@edges.keys.size} edges)"
  end
end
 
# A path is a sequence of elements that can be treated as a single element leading between the vectors +from+ and +to+
class Path
  def initialize(entities, vertices)
    @entities = entities
    @vertices = vertices
    @from = vertices.first
    @to = vertices.last
    @extent = nil
  end   
  
  def loop?
    @from =~ @to
  end
  
  def entities
    @entities
  end  
  
  def vertices
    @vertices
  end
  
  def from
    @from
  end
  
  def to
    @to
  end
  
end    
     
# Represents a set of entities as a graph of paths. Each path representing a non-branching
# sequence of elements.
class PathGraph
  def initialize(entities)
    @adjacency_graph = AdjacencyGraph.new(entities)  
    # the nodes of this graph consists of the branching nodes of the adjacency graph
    @odd_vertices = []
    @vertices = {}
    @adjacency_graph.vertices.each do |vertex|
      @odd_vertices << vertex if (@adjacency_graph.entities_connected_to(vertex).size % 2) != 0
    end
    @edges = {}
    @processed_entities = []

    # First generate all paths originating from branching and dead end nodes
    (@odd_vertices).each do |vertex|     
      generate_paths_from(vertex)      
    end
    # Then do the rest of the paths by picking random vertices until we have processed all 
    # entities.
    while true
      remaining_entities = entities-@processed_entities
      break if remaining_entities.empty?
      generate_paths_from(remaining_entities.first.from)
    end    
  end
  
  def generate_paths_from(vertex)
    leads = @adjacency_graph.entities_connected_to(vertex)
    leads.each do |entity|
      path = generate_path(vertex, entity)
      next if path.nil?  
      if path.loop?
        path.vertices.each do |vertex|
          @vertices[vertex] ||= []
          @vertices[vertex] << path
        end
      else
        @vertices[path.from] ||= []
        @vertices[path.from] << path
        @vertices[path.to] ||= []
        @vertices[path.to] << path
      end
      @edges[path] = [path.from, path.to] 
    end
  end
  
  def generate_path(start_vertex, first_entity)
    return if @processed_entities.include?(first_entity)
    entities = []
    vertices = []
    entity = first_entity        
    vertex = start_vertex
    done = false
    
    vertices << vertex
    while true 
      entities << entity   
      @processed_entities << entity 
      # traverse to next vertex
      vertex = @adjacency_graph.destination_vertex(vertex, entity)
      vertices << vertex
      break if @odd_vertices.include?(vertex) # if this is a branching or dead-end vertex the path is done
      # find next entity to traverse      
      entity = (@adjacency_graph.entities_connected_to(vertex)-[entity]).first
      # if there are no more entities, this is a dead end. If we have reached a processed entity, this is 
      # certainly a loop, and we have just completed it
      break if entity.nil? || @processed_entities.include?(entity) 
    end                                
    
    Path.new(entities, vertices)
  end
  
  def loop_vertices
    @loop_vertices
  end
  
  def paths
    @edges.keys
  end
  
  def vertices
    @vertices
  end    
  
  def inspect
    "PathGraph(#{@branch_vectors.size} branch-points, #{@end_vectors.size} end-points, #{@edges.keys.size} paths)"
  end
end
