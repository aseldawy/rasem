
require 'svg_documentation.rb'

class Rasem::SVGTag
  @@elements = {
    :animation => ["animate", "animateColor", "animateMotion", "animateTransform", "set"],
    :description => ["desc", "metadata", "title"],
    :shape => ["circle", "elipse", "line", "path", "polygon", "polyline", "rect"],
    :structure => ["defs", "g", "svg", "symbol", "use"],
    :gradient => ["linearGradient", "radialGradient"],
    :other => ["a", "color-profile", "cursor", "filter", "font", "image", "marker", "mask", "pattern", "script", "style", "switch", "text", "view"],
  }

  @@attributes = {
  }

  @@valid_children = {
    :svg    => [ @@elements.values ].flatten!,
    :g      => [ @@elements.values ].flatten!,
  }

  @@aliases = {
    :group  => :g,
    :description => :desc,
  }

  #complete documentation as in w3.org
  @@svg_standard = {
    :svg    => 
    {
      :allowed_elements => [ @@elements.values ].flatten!,
      :allowed_attributes => 

    },
  }

  attr_reader :tag, :parent, :child

  def initialize(tag, params={})
    @output = bind_output(params.delete :output)
    @parent = params.delete :parent
    @tag = bind_tag(tag)
    @params = bind_params(params)
  end

  def bind_output(output)
    if output.nil?
      ""
    elsif output.respond_to?(:<<)
      output
    else
      raise "Illegal output object: #{output.inspect}"
    end
  end

  def bind_tag(tag)
    #TODO: make tag string validation?
    tag
  end

  def bind_params(params)
    #TODO: make a list of valid parameters for all tags (see SVG docs)
    params
  end

  def open(oneline = false)
    raise "Should not open a tag repeatedly!" if @open
    @parent.open_child(self) if @parent
    @output << "<#{@tag} "
    @params.each do |parameter, value|
      @output << "#{parameter}=\"#{value}\" "
    end
    if oneline
      @output << "/>"
      @parent.close_child(self) if @parent
    else
      @output << ">"
      @open = true
    end
  end

  def opened?
    @open
  end

  def open_close()
    open(true)
  end

  def close()
    raise "Should open a tag in order to close it!" unless @open
    @output << "</#{@tag}>"
    @open = false
    @parent.close_child(self) if @parent
  end

  def closed?
    not @open
  end

  def output()
    @output.to_s
  end
end



class Rasem::SVGContainer < Rasem::SVGTag
  def initialize(tag, params={}, &block)
    super(tag,params)
    @children = []
    @child = nil
    if block
      self.open()
      instance_exec &block
      self.close()
    end
  end

  def spawn_child(tag, params={}, &block)
    raise "Tag #{@tag} contains not closed child! May not add another in this scope." if @child
    #Pass output and self down the hierarchy
    params[:output] = @output
    params[:parent] = self
    @child = Rasem::SVGContainer.new(tag, params, &block)
  end

  def method_missing(meth, *args, &block)
    if @@valid_children[@tag.to_sym].include?(meth.to_s)
      spawn_child(meth.to_s, *args, &block)
    else
      super
    end
  end

  def open_child(child)
    raise "Bad hierarchy" unless child.parent == self
    @child = child
  end
  
  def close_child(child)
    raise "Bad hierarchy" unless @child == child
    #Append closed child to children list.
    @children.push(child)
    @child = nil
  end
  
end


class Rasem::SVGImage
  DefaultStyles = {
    :text => {:fill=>"black"},
    :line => {:stroke=>"black"},
    :rect => {:stroke=>"black"},
    :circle => {:stroke=>"black"},
    :ellipse => {:stroke=>"black"},
    :polygon => {:stroke=>"black"},
    :polyline => {:stroke=>"black"}
  }


  def initialize(params = {}, output=nil, &block)
    @output = create_output(output)

    params["version"] = "1.1" unless params["version"]
    params["xmlns"] = "http://www.w3.org/2000/svg" unless params["xmlns"]
    params["xmlns:xlink"] = "http://www.w3.org/1999/xlink" unless params["xmlns:xlink"]
    params[:output] = @output

    write_header()

    @svg = Rasem::SVGContainer.new("svg", params, &block)

    #auto open file tag.
    @svg.open() unless block

    # Initialize a stack of default styles
    @default_styles = []

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

  # draw an image
  def image(x, y, width, height, href)
    @output << %Q{<image x="#{x}" y="#{y}" height="#{height}" width="#{width}" xlink:href="#{href}"}
    @output << %Q{/>}
  end

  # Draw a straight line between the two end points
  def line(x1, y1, x2, y2, style=DefaultStyles[:line])
    @output << %Q{<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}"}
    write_style(style)
    @output << %Q{/>}
  end

  # Draw a circle given a center and a radius
  def circle(cx, cy, r, style=DefaultStyles[:circle])
    @output << %Q{<circle cx="#{cx}" cy="#{cy}" r="#{r}"}
    write_style(style)
    @output << %Q{/>}
  end

  # Draw a rectangle or rounded rectangle
  def rectangle(x, y, width, height, *args)
    style = (!args.empty? && args.last.is_a?(Hash)) ? args.pop : DefaultStyles[:rect]
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
  def ellipse(cx, cy, rx, ry, style=DefaultStyles[:ellipse])
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
  end

  def output
    @output.to_s
  end

  def closed?
    @svg.closed?
  end

  def with_style(style={}, &proc)
    # Merge passed style with current default style
    updated_style = default_style.merge(style)
    # Push updated style to the stack
    @default_styles.push(updated_style)
    # Call the block
    self.instance_exec(&proc)
    # Pop style again to revert changes
    @default_styles.pop
  end

  def group(style={}, transforms={}, &proc)
    # Open the group
    @output << "<g"
    write_style(style)
    write_transforms(transforms)
    @output << ">"
    # Call the block
    self.instance_exec(&proc)
    # Close the group
    @output << "</g>"
  end

  def text(x, y, text, style=DefaultStyles[:text])
    @output << %Q{<text x="#{x}" y="#{y}"}
    style = fix_style(default_style.merge(style))
    @output << %Q{ font-family="#{style.delete "font-family"}"} if style["font-family"]
    @output << %Q{ font-size="#{style.delete "font-size"}"} if style["font-size"]
    write_style style
    @output << ">"
    dy = 0      # First line should not be shifted
    text.each_line do |line|
      @output << %Q{<tspan x="#{x}" dy="#{dy}em">}
      dy = 1    # Next lines should be shifted
      @output << line.rstrip
      @output << "</tspan>"
    end
    @output << "</text>"
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
  def write_header()
    @output << <<-HEADER
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    HEADER
  end

  # Write the closing tag of the file
  def write_close
    @svg.close()
  end

  # Draws either a polygon or polyline according to the first parameter
  def polything(name, *args)
    return if args.empty?
    style = (args.last.is_a?(Hash)) ? args.pop : DefaultStyles[name.to_sym]
    coords = args.flatten
    raise "Illegal number of coordinates (should be even)" if coords.length.odd?
    @output << %Q{<#{name} points="}
    until coords.empty? do
      x = coords.shift
      y = coords.shift
      @output << "#{x},#{y}"
      @output << " " unless coords.empty?
    end
    @output << '"'
    write_style(style)
    @output << '/>'
  end

  # Return current deafult style
  def default_style
    @default_styles.last || {}
  end

  # Returns a new hash for styles after fixing names to match SVG standard
  def fix_style(style)
    new_style = {}
    style.each_pair do |k, v|
      new_k = k.to_s.gsub('_', '-')
      new_style[new_k] = v
    end
    new_style
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
    style_ = fix_style(default_style.merge(style))
    return if style_.empty?
    @output << ' style="'
    style_.each_pair do |attribute, value|
      @output << "#{attribute}:#{value};"
    end
    @output << '"'
  end

  def write_transforms(transforms)
    return if transforms.empty?
    @output << ' transform="'
    transforms.each_pair do |attribute, value|
      value = [value] unless value.is_a?(Array)
      @output << "#{attribute}(#{value.join(',')})"
    end
    @output << '"'
  end


end

