class Rasem::SVGImage
  DefaultStyle = {:stroke=>"black", :fill=>"black"}

  def initialize(*args, &block)
    if args.length == 3
      @output = create_output(args.shift)
    else
      @output = create_output(nil)
    end
    
    # Initialize a stack of default styles
    @default_styles = [DefaultStyle]

    write_header(*args)
    if block
      self.instance_exec(&block)
      self.close
    end
  end
  
  def set_width(new_width)
    if @output.respond_to?(:sub!)
      @output.sub!(/<svg width="[^"]+"/, %Q{<svg width="#{new_width}"})
    else
      raise "Cannot change width after initialization for this output"
    end
  end
  
  def set_height(new_height)
    if @output.respond_to?(:sub!)
      @output.sub!(/<svg width="([^"]+)" height="[^"]+"/, %Q{<svg width="\\1" height="#{new_height}"})
    else
      raise "Cannot change width after initialization for this output"
    end
  end

  # Draw a straight line between the two end points
  def line(x1, y1, x2, y2, style={})
    @output << %Q{<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}"}
    write_style(style)
    @output << %Q{/>}
  end
  
  # Draw a circle given a center and a radius
  def circle(cx, cy, r, style={})
    @output << %Q{<circle cx="#{cx}" cy="#{cy}" r="#{r}"}
    write_style(style)
    @output << %Q{/>}
  end
 
  # Draw a rectangle or rounded rectangle 
  def rectangle(x, y, width, height, *args)
    style = (!args.empty? && args.last.is_a?(Hash)) ? args.pop : {}
    if args.length == 0
      rx = ry = 0
    elsif args.length == 1
      rx = ry = args.pop
    elsif args.length == 2
      rx, ry = args
    else
      raise "Illegal number of arguments to rectangle"
    end
      
    @output << %Q{<rect x="#{x}" y="#{y}" width="#{width}" height="#{height}"}
    @output << %Q{ rx="#{rx}" ry="#{ry}"} if rx && ry
    write_style(style)
    @output << %Q{/>}
  end
 
  # Draw an circle given a center and two radii
  def ellipse(cx, cy, rx, ry, style={})
    @output << %Q{<ellipse cx="#{cx}" cy="#{cy}" rx="#{rx}" ry="#{ry}"}
    write_style(style)
    @output << %Q{/>}
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
  
  def with_style(style={}, &proc)
    # Merge passed style with current default style
    updated_style = default_style.update(style)
    # Push updated style to the stack
    @default_styles.push(updated_style)
    # Call the block
    self.instance_exec(&proc)
    # Pop style again to revert changes
    @default_styles.pop
  end

  def group(style={}, &proc)
    # Open the group
    @output << "<g"
    write_style(style)
    @output << ">"
    # Call the block
    self.instance_exec(&proc)
    # Close the group
    @output << "</g>"
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
    style = (args.last.is_a?(Hash)) ? args.pop : {}
    coords = args.flatten
    raise "Illegal number of coordinates (should be even)" if coords.length.odd?
    @output << %Q{<#{name} points="}
    until coords.empty? do
      x = coords.shift
      y = coords.shift
      @output << "#{x},#{y}"
      @output << " " unless coords.empty?
    end
    write_style(style)
    @output << '"/>'
  end
  
  # Return current deafult style
  def default_style
    @default_styles.last || {}
  end
  
  # Writes styles to current output
  # Avaialable styles are:
  # fill: Fill color
  # stroke-width: stroke width
  # stroke: stroke color
  # fill-opacity: fill opacity. ranges from 0 to 1
  # stroke-opacity: stroke opacity. ranges from 0 to 1
  # opacity: Opacity for the whole element
  def write_style(style)
    style_ = default_style.merge(style)
    return if style_.empty?
    @output << ' style="'
    style_.each_pair do |style, value|
      @output << "#{style.to_s.gsub('_','-')}:#{value};"
    end
    @output << '"'
  end
end
