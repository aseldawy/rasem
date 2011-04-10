class Rasem::SVGImage

  def initialize(*args, &block)
    if args.length == 3
      @output = create_output(args.shift)
    else
      @output = create_output(nil)
    end

    write_header(*args)
    if block
      self.instance_exec(&block)
      self.close
    end
  end

  # Draw a straight line between the two end points
  def line(x1, y1, x2, y2)
    @output << %Q{<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}"/>}
  end
  
  # Draw a circle given a center and a radius
  def circle(cx, cy, r)
    @output << %Q{<circle cx="#{cx}" cy="#{cy}" r="#{r}"/>}
  end
 
  # Draw a rectangle or rounded rectangle 
  def rectangle(x, y, width, height, rx=nil, ry=rx)
    @output << %Q{<rect x="#{x}" y="#{y}" width="#{width}" height="#{height}"}
    @output << %Q{ rx="#{rx}" ry="#{ry}"} if rx && ry
    @output << %Q{/>}
  end
 
  # Draw an circle given a center and two radii
  def ellipse(cx, cy, rx, ry)
    @output << %Q{<ellipse cx="#{cx}" cy="#{cy}" rx="#{rx}" ry="#{ry}"/>}
  end
  
  def polygon(*args)
    polything("polygon", *args)
  end
   
  def polyline(*args)
    polything("polyline", *args)
  end
  
  # Closes the file. No more drawing is possible after this
  def close
    write_close
    @closed = true
  end
  
  def output
    @output.to_s
  end
  
  def closed?
    @closed
  end
  
private
  # Creates an object for ouput out of an argument
  def create_output(arg)
    if arg.nil?
      ""
    elsif arg.respond_to?(:<<)
      arg
    else
      raise "Illegal output object: #{arg.inspect}"
    end
  end
  
  # Writes file header
  def write_header(width, height)
    @output << <<-HEADER
      <?xml version="1.0" standalone="no"?>
      <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
        "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
      <svg width="#{width}" height="#{height}" version="1.1"
        xmlns="http://www.w3.org/2000/svg">
    HEADER
  end
  
  # Write the closing tag of the file
  def write_close
    @output << "</svg>"
  end
  
  # Draws either a polygon or polyline according to the first parameter
  def polything(name, *args)
    return if args.empty?
    coords = args.flatten
    raise "Illegal number of coordinates (should be even)" if coords.length.odd?
    @output << %Q{<#{name} points="}
    until coords.empty? do
      x = coords.shift
      y = coords.shift
      @output << "#{x},#{y}"
      @output << " " unless coords.empty?
    end
    @output << %{"/>}
  end
end
