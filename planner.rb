# A module to plan a plotting operation

require 'layers'
require 'entities'

class Plan
  def initialize(layer, initial_position = Vector.new(0.0, 0.0, 0.0))
    @plan = []
    @layer = layer
    @processed_paths = []
    @vertices = layer.path_graph.vertices
    vector, path = seek_best_point_and_path(initial_position)
    @plan << [:seek, vector]
    while true      
      if path
        @plan << [:trace, path, vector]
        @processed_paths << path
        vector = path.to
      end
      original_vector = vector
      vector, path = seek_best_point_and_path(vector)
      break unless vector
      @plan << [:seek, vector] if original_vector != vector
    end
  end
  
  def steps
    @plan
  end
  
  def gcodes
    code = ["G90"]
    @plan.each do |step|
      case step[0]
      when :seek
        code << "G0 X#{step[1].x} Y#{-step[1].y} Z#{step[1].z}"
      when :trace
        path = step[1]
        vertices = path.vertices
        vertex = step[2]
        start_index = vertices.index(vertex)
        if path.loop? 
          # trace round
          (0..vertices.size).each do |index|
            vertex = vertices[(index+start_index) % vertices.size]
            code << "G1 X#{vertex.x} Y#{-vertex.y} Z#{vertex.z}"
          end
        elsif path.from == vertex
          # trace forward
          (0...vertices.size).each do |index|
            vertex = vertices[(index+start_index) % vertices.size]
            code << "G1 X#{vertex.x} Y#{-vertex.y} Z#{vertex.z}"
          end
        else
          # trace reverse
          (0...vertices.size).each do |index|
            vertex = vertices[(start_index-index) % vertices.size]
            code << "G1 X#{vertex.x} Y#{-vertex.y} Z#{vertex.z}"
          end
        end
      end
    end
    code.join("\n\r")
  end

private
  
  def seek_best_point_and_path(origin)
    badness_score = 99999999999.0
    best_vector = nil
    best_path = nil
    @vertices.keys.each do |vector|
      unprocessed = @vertices[vector]-@processed_paths
      next if unprocessed.empty?
      d = vector.distance(origin)
      unprocessed.each do |path|
        s = d+origin.distance(origin.farthest(path.vertices))/8
        if d<badness_score
          best_vector = vector
          best_path = path
          badness_score = s
        end
      end
    end
    [best_vector, best_path]
  end
end
  