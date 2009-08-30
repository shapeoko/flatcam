require 'optparse'
require 'dxffile'
require 'entities'
require 'layers'
require 'planner'
  
$verbose = false

def say(message)
  puts message if $verbose
end

outfile = nil
layername = nil

options_parser = OptionParser.new do |opts|
  opts.banner = "Usage: flatcam [options] dxf-file"
  opts.on('-v', '--verbose', 'Output more information') do
    $verbose = true
  end   
  
  opts.on('-g', '--gcode FILENAME', 'Output gcode to file') do |file|
    outfile = file
  end
  
  opts.on('-l', '--layer LAYER', 'Process specific layers (default: all)') do |identifier|
    layername = identifier.to_sym
  end
  
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end
options_parser.parse!

if ARGV.empty?
  puts options_parser
  exit
end

layers = {}
ARGV.each do |file|
  say "Parsing source file '#{file}'..."
  DxfFile.read(File.new(file, 'r')) do |object|    
    layers[object[:layer]] ||= Layer.new(object[:layer])
    klass = GeometricEntity.class_for_type(object[:type])
    if klass
      layers[object[:layer]] << klass.new(object)
    else
      say "No mapped class for geometric entity of type #{object[:type]}"
    end
  end  
end

if layers.keys.size > 0
  say("Layers")
  layers.keys.each do |key|
    say("  #{key} (#{layers[key].entities.count} entities)")
  end
  say ""
else
  puts "Nothing to do."
  exit
end

if layername
  unless layers[layername] 
    puts "No layer named #{layername}. Try #{layers.keys.join(' or ')}."
    exit
  end
  say "Processing layer '#{layername}'"
  gcode = Plan.new(layers[layername]).gcodes
else
  say "Merging layers"
  merged = Layer.new('merged')
  say "Processing merged layers"
  layers.values.each do |layer|
    merged.merge(layer)
  end
  gcode = Plan.new(merged).gcodes
end

if outfile     
  say "Dumping gcode to '#{outfile}'"
  File.open(outfile,'w') do |file|
    file << gcode+"\n\r"
  end
else
  puts gcode
end
    