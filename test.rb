require 'dxffile'
require 'entities'
require 'layers'
require 'pp'
require 'planner'
           
layers = {}
DxfFile.read(File.new('testpattern.dxf', 'r')) do |object|
#DxfFile.read(File.new('/Users/simen/_dev/hardware/twister/models/twister-z-axis-rev1.dxf', 'r')) do |object|
#DxfFile.read(File.new('/Users/simen/Desktop/drawing.dxf', 'r')) do |object|
  layers[object[:layer]] ||= Layer.new(object[:layer])
  klass = GeometricEntity.class_for_type(object[:type])
  if klass
    layers[object[:layer]] << klass.new(object)
  else
    raise "No mapped class for geometric entity of type #{object[:type]}"
  end
end

pp layers
puts Plan.new(layers[layers.keys.first]).gcodes