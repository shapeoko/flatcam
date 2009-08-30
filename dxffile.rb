class DxfFile
  def self.read(file, &block)
    chunk = {}
    group_code_line = true
    group_code = nil
    file.each_line("\r") do |line|
      line = line.strip
      if group_code_line
        group_code = line.to_i
        if group_code == 0 # designates the start of a new chunk
          case chunk[0]
          when 'SECTION'
            raise "Nested sections not supported" if @current_section
            @current_section = chunk[2].downcase.to_sym
          when 'ENDSEC'
            @current_section = nil
          else
            case @current_section
            when :entities
              layer = chunk[8].downcase.to_sym
              object = nil
              case chunk[0]
              when 'LINE'
                object = 
                  {:type => :line, :from => [chunk[10], chunk[20], chunk[30]], :to => [chunk[11], chunk[21], chunk[31]],
                    :color => chunk[62], :handle => chunk[5], :layer => layer}
              when 'CIRCLE'
                object = 
                  {:type => :circle, :center => [chunk[10], chunk[20], chunk[30]], :radius => chunk[40], :color => chunk[62],
                    :handle => chunk[5], :layer => layer}
              when 'ARC'
                object = 
                  {:type => :arc, :center => [chunk[10], chunk[20], chunk[30]], :radius => chunk[40], :color => chunk[62],
                    :from_degrees => chunk[50], :to_degrees => chunk[51],
                    :handle => chunk[5], :layer => layer}
              when 'TEXT'
                object = 
                  {:type => :text, :string => chunk[1], :linetype => chunk[6],
                    :position => [chunk[10], chunk[20], chunk[30]], :scale => chunk[40], :color => chunk[62],              
                    :handle => chunk[5], :layer => layer}
              when 'VIEWPORT'
                # ignore
              else
                puts "Warning: Unhandled entity type '#{chunk[0]}'"
              end
            end
            if object
              yield(object)
            end
          end
          chunk = {} # clear entity
        end
      else
        # Convert string to an appropriate data type according to this table
        # http://www.autodesk.com/techpubs/autocad/acad2000/dxf/group_code_value_types_dxf_01.htm
        case group_code
        when 10...59 # Double precision 3D point
          value = line.to_f
        when 60..99 # Integer
          value = line.to_i
        when 140..147 # Double precision scalar floating-point value
          value = line.to_f
        when 170..289 # Integer
          value = line.to_i
        when 310..369 # Hex integer
          value = line.to_i(16)
        when 370..389 # integer
          value = line.to_i
        when 390..399 # hex
          value = line.to_i(16)
        when 400..409 # integer
          value = line.to_i
        when 1010..1059 # float
          value = line.to_f
        when 1060..1070 # integer
          value = line.to_i
        else
          value = line
        end
        chunk[group_code] ||= value
      end
      
      # Every other line is a group code line
      group_code_line = !group_code_line
      
    end
  end
end
