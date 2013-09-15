Rasem::SVG_ALIAS = {
  :group  => :g,
  :rectangle => :rect,
}

Rasem::SVG_EXPANSION = {
  :line   => [:x1,:y1,:x2,:y2],
  :circle => [:cx,:cy,:r],
  :image  => [:x,:y,:width,:height,:"xlink:href"],
  :ellipse => [:cx,:cy,:rx,:ry],
  :text   => [:x,:y],

  :rect   => lambda do |args|
  raise "Wrong unnamed argument count" unless args.size == 4 or args.size == 5 or args.size == 6
  result = {
    :x => args[0],
    :y => args[1],
    :width => args[2],
    :height => args[3],
  }
  if (args.size > 4)
    result[:rx] = args[4]
    result[:ry] = (args[5] or args[4])
  end
  return result
  end,

  :polygon => lambda do |args|
  args.flatten!
  raise "Illegal number of coordinates (should be even)" if args.length.odd?
  return {
    :points => args
  }
  end,

  :polyline => lambda do |args|
  args.flatten!
  raise "Illegal number of coordinates (should be even)" if args.length.odd?
  return {
    :points => args
  }
  end
}

Rasem::SVG_DEFAULTS = {
  :text => {:fill=>"black"},
  :line => {:stroke=>"black"},
  :rect => {:stroke=>"black"},
  :circle => {:stroke=>"black"},
  :ellipse => {:stroke=>"black"},
  :polygon => {:stroke=>"black"},
  :polyline => {:stroke=>"black"},
}

#TODO: move to documentation?
Rasem::SVG_TRANSFORM = [
  :matrix,    # expects an array of 6 elements
  :translate, #[tx, ty?]
  :scale,     #[sx, sy?]
  :rotate,    #[angle, (cx, cy)?]
  :skewX,     # angle
  :skewY,     # angle
]

Rasem::CSS_STYLE = [
  :fill,
  :stroke_width,
  :stroke,
  :fill_opacity,
  :stroke_opacity,
  :opacity,
]

class Rasem::SVGRaw
  def initialize(data)
    @data = data
  end

  def write(output)
    output << @data.to_s
  end
end

class Rasem::SVGTag
  attr_reader :tag, :attributes, :children

  def initialize(tag, attributes={}, &block)
    @tag = validate_tag(tag)
    @attributes = validate_attributes(attributes)
    @children = []
    if block
      instance_exec &block
    end
  end

  def validate_tag(tag)
    raise "#{tag} is not a valid tag" unless Rasem::SVG_ELEMENTS.include?(tag.to_sym)
    tag.to_sym
  end

  def validate_attributes(attributes)
    clean_attributes = {}
    transforms = {}
    styles = {}
    attributes.each do
      |attribute, value|
      if Rasem::SVG_TRANSFORM.include? attribute
        transforms[attribute] = value
      elsif Rasem::CSS_STYLE.include? attribute
        styles[attribute] = value
      else
        clean_attributes[validate_attribute(attribute)] = value
      end
    end
    #always prefer more verbose definition.
    unless transforms.empty?
      transforms.merge!(clean_attributes[:transform]) if clean_attributes[:transform]
      clean_attributes[validate_attribute(:transform)] = transforms
    end
    unless styles.empty?
      styles.merge!(clean_attributes[:style]) if clean_attributes[:style]
      clean_attributes[validate_attribute(:style)] = styles
    end
    clean_attributes
  end

  def validate_attribute(attribute)
    raise "#{@tag} does not support attribute #{attribute}" unless Rasem::SVG_STRUCTURE[@tag.to_sym][:attributes].include?(attribute.to_sym)
    attribute.to_sym
  end

  def write_styles(styles, output)
    styles.each do |attribute, value|
      attribute = attribute.to_s
      attribute.gsub!('_','-')
      output << "#{attribute}:#{value};"
    end
  end

  def write_transforms(transforms, output)
    transforms.each do |attribute, value|
      value = [value] unless value.is_a?(Array)
      output << "#{attribute.to_s}(#{value.join(',')}) "
    end
  end

  def write_points(points, output)
    points.each_with_index do |value, index|
      output << value.to_s
      output << ',' if index.even?
      output << ' ' if (index.odd? and (index != points.size-1))
    end
  end

  #special case for raw blocks.
  def raw(data)
    child = Rasem::SVGRaw.new(data)
    @children.push(child)
    child
  end

  def spawn_child(tag, *args, &block)
    #expected args: nil, [hash], [...]
    parameters = {} if args.size == 0
    unless parameters #are empty
      parameters = args[0] if args[0].is_a? Hash
    end
    unless parameters #are set
      #try to find args expansion rule
      expansion = Rasem::SVG_EXPANSION[tag.to_sym]
      raise "Unnamed parameters for #{tag} are not allowed!" unless expansion
      if expansion.is_a? Array
        raise "Bad unnamed parameter count for #{tag}, expecting #{expansion.size} got #{if args.last.is_a? Hash then args.size-1 else args.size end}" unless (args.size == expansion.size and not args.last.is_a? Hash) or (args.size - 1 == expansion.size and args.last.is_a? Hash)
        parameters = Hash[expansion.zip(args)]
        if args.last.is_a? Hash
          parameters.merge! args.last
        end
    elsif expansion.is_a? Proc
      hash = args.pop if args.last.is_a? Hash
      parameters = expansion.call(args)
      parameters.merge! hash if hash
    else
      raise "Unexpected expansion mechanism: #{expansion.class}"
    end
  end
  # add default parameters if they are not overwritten
  merge_defaults().each do |key, value|
    parameters[key] = value unless parameters[key]
  end if @defaults
  Rasem::SVG_DEFAULTS[tag.to_sym].each do |key, value|
    parameters[key] = value unless parameters[key]
  end if Rasem::SVG_DEFAULTS[tag.to_sym]

  append_child(Rasem::SVGTag.new(tag, parameters, &block))
end

def append_child(child)
  @children.push(child)
  child.push_defaults(merge_defaults()) if @defaults
  child
end

def merge_defaults()
  result = {}
  return result if @defaults.empty?
  @defaults.each { |d| result.merge!(d) }
  result
end

def push_defaults(defaults)
  @defaults = [] unless @defaults
  @defaults.push(defaults)
end

def pop_defaults()
  @defaults.pop()
end

def with_style(style={}, &proc)
  push_defaults(style)
  # Call the block
  self.instance_exec(&proc)
  # Pop style again to revert changes
  pop_defaults()
end

def validate_child_name(name)
  #aliases the name (like, group instead of g)
  name = Rasem::SVG_ALIAS[name.to_sym] if Rasem::SVG_ALIAS[name.to_sym]
  #raises only if given name is an actual svg tag. In other case -- assumes user just mistyped.
  if Rasem::SVG_STRUCTURE[@tag.to_sym][:elements].include?(name.to_sym)
    name.to_sym
  elsif Rasem::SVG_ELEMENTS.include?(name.to_sym)
    raise "#{@tag} should not contain child #{name}" 
  end
end

def method_missing(meth, *args, &block)
  #if method is a setter or a getter, check valid attributes:
  check = /^(?<name>.*)(?<op>=|\?)$/.match(meth)
  if check
    raise "Passing a code block to setter or getter is not permited!" if block
    name = validate_attribute(check[:name].to_sym)
    if check[:op] == '?'
      @attributes[name]
    elsif check[:op] == '='
      raise "Setting an attribute with multiple values is not permited!" if args.size > 1
      @attributes[name] = args[0]
    end
  elsif child = validate_child_name(meth)
    spawn_child(child, *args, &block)
  else
    super
  end
end

def write(output)
  raise "Can not write to given output!" unless output.respond_to?(:<<)
  output << "<#{@tag.to_s}"
  @attributes.each do
    |attribute, value|
    output << " #{attribute.to_s}=\""
    if attribute == :transform
      write_transforms(value, output)
    elsif attribute == :style
      write_styles(value, output)
    elsif attribute == :points
      write_points(value, output)
    else
      output << "#{value.to_s}"
    end
    output << "\""
  end
  if @children.empty?
    output << "/>"
  else
    output << ">"
    @children.each { |c| c.write(output) }
    output << "</#{@tag.to_s}>"
  end
end
end

class Rasem::SVGImage < Rasem::SVGTag


  def initialize(params = {}, output=nil, &block)
    params[:"version"] = "1.1" unless params[:"version"]
    params[:"xmlns"] = "http://www.w3.org/2000/svg" unless params[:"xmlns"]
    params[:"xmlns:xlink"] = "http://www.w3.org/1999/xlink" unless params[:"xmlns:xlink"]
    super("svg", params, &block)

    @output = (output or "")
    validate_output(@output) if output

    if block
      write(@output)
    end
  end


  #def text(x, y, text, style=DefaultStyles[:text])
  #  @output << %Q{<text x="#{x}" y="#{y}"}
  #  style = fix_style(default_style.merge(style))
 #   @output << %Q{ font-family="#{style.delete "font-family"}"} if style["font-family"]
 #   @output << %Q{ font-size="#{style.delete "font-size"}"} if style["font-size"]
 #   write_style style
 #   @output << ">"
 #   dy = 0      # First line should not be shifted
 #   text.each_line do |line|
 #     @output << %Q{<tspan x="#{x}" dy="#{dy}em">}
 #     dy = 1    # Next lines should be shifted
 #     @output << line.rstrip
 #     @output << "</tspan>"
 #   end
 #   @output << "</text>"
 # end

  def write(output)
    validate_output(output)
    write_header(output)
    super(output)
  end

  # how to define output << image ?
  #def <<(output)
  #  write(output)
  #end

  private
  def validate_output(output)
    raise "Illegal output object: #{output.inspect}" unless output.respond_to?(:<<)
  end

  # Writes file header
  def write_header(output)
    output << <<-HEADER
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    HEADER
  end

end

