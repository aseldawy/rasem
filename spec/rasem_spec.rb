require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGTag do
  it "should create an empty tag" do
    tag = Rasem::SVGTag.new("svg")
    tag.open_close
    str = tag.output
    str.should =~ %r{<svg />}
  end 

  it "should create a tag with parameters" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    tag.open_close
    str = tag.output
    str.should =~ %r{<svg width="100%" height="100%" />}
  end 

  it "should write to supplied buffer" do
    output = ""
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%", :output=>output)
    tag.open_close
    output.should =~ %r{<svg width="100%" height="100%" />}
  end 

  it "should call parent method on opening and closing" do
    parent = mock("parent")
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%", :parent=>parent)
    parent.should_receive('open_child').with(tag)
    parent.should_receive('close_child').with(tag)
    tag.open_close
  end 

  it "should call spawn_child if possible to add that child" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    tag.should_receive('spawn_child').with('g')
    tag.g
  end 

  it "should not call spawn_child if possible to add that child" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    tag.should_not_receive('spawn_child').with('ggr')
    expect { tag.ggr }.to raise_error
  end 
end

describe Rasem::SVGContainer do
  it "should create an empty tag" do
    con = Rasem::SVGContainer.new("svg")
    con.open_close
    str = con.output
    str.should =~ %r{<svg />}
  end

  it "should allow to execute a block within" do
    con = Rasem::SVGContainer.new("svg") do
    end
    str = con.output
    str.should =~ %r{<svg ></svg>}
  end

  it "should insert a child from block within" do
    con = Rasem::SVGContainer.new("svg",:height=>"100%") do
      g :height=>"10" do
      end
    end
    str = con.output
    str.should =~ %r{<svg height="100%" ><g height="10" ></g></svg>}
  end

  it "should insert a child by method call" do
    svg = Rasem::SVGContainer.new("svg",:height=>"100%")
    svg.open
    g = svg.g :id=>"G1"
    g.open_close
    g = svg.g :id=>"G2"
    g.open_close
    svg.close
    str = svg.output
    str.should =~ %r{<svg height="100%" ><g id="G1" /><g id="G2" /></svg>}
  end

  it "should nest easily" do
    svg = Rasem::SVGContainer.new("svg") do
      g do
        g do
          g do
            g do
            end
          end
        end
      end
    end
    svg.output.should =~ %r{<svg ><g ><g ><g ><g ></g></g></g></g></svg>}
  end
end

describe Rasem::SVGImage do
  it "should initialize an empty image" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    str = img.output
    str.should =~ %r{width="100"}
    str.should =~ %r{height="100"}
  end

  it "should initialize XML correctly" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    str = img.output
    str.should =~ /^<\?xml/
  end

  it "should close an image" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    img.close
    str = img.output
    str.should =~ %r{</svg>}
  end

  it "should auto close an image with block" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
    end
    img.should be_closed
  end
  
  it "should draw line using method" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    img.line(0, 0, 100, 100)
    img.close
    str = img.output
    str.should =~ %r{<line}
    str.should =~ %r{x1="0"}
    str.should =~ %r{y1="0"}
    str.should =~ %r{x2="100"}
    str.should =~ %r{y2="100"}
  end
  
  it "should draw line using a block" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      line(0, 0, 100, 100)
    end
    str = img.output
    str.should =~ %r{<line}
    str.should =~ %r{x1="0"}
    str.should =~ %r{y1="0"}
    str.should =~ %r{x2="100"}
    str.should =~ %r{y2="100"}
  end

  it "should draw a line with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      line(0, 0, 10, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a circle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      circle(0, 0, 10)
    end
    str = img.output
    str.should =~ %r{<circle}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{r="10"}
  end

  it "should draw a circle with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      circle(0, 0, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a rectangle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 100, 300)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
  end

  it "should draw a rectangle with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 10, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a symmetric round-rectangle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 100, 300, 20)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
    str.should =~ %r{rx="20"}
    str.should =~ %r{ry="20"}
  end

  it "should draw a symmetric rounded-rectangle with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 10, 10, 2, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a non-symmetric round-rectangle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 100, 300, 20, 5)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
    str.should =~ %r{rx="20"}
    str.should =~ %r{ry="5"}
  end

  it "should draw a non-symmetric rounded-rectangle with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 10, 10, 2, 4, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end
  
  it "should draw an ellipse" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      ellipse(0, 0, 100, 300)
    end
    str = img.output
    str.should =~ %r{<ellipse}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{rx="100"}
    str.should =~ %r{ry="300"}
  end

  it "should draw an ellipse with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      ellipse(0, 0, 3, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a polygon given an array of points" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      polygon([[0,0], [1,2], [3,4]])
    end
    str = img.output
    str.should =~ %r{<polygon}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should draw a polygon with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      polygon([[0,0], [1,2], [3,4]], :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a polyline given an array of points" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      polyline([[0,0], [1,2], [3,4]])
    end
    str = img.output
    str.should =~ %r{<polyline}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should fix style names" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      circle(0, 0, 10, :stroke_width=>3)
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
  end
  
  it "should group styles" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      with_style :stroke_width=>3 do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
  end

  it "should group styles nesting" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      with_style :stroke_width=>3 do
        with_style :fill=>"black" do
          circle(0, 0, 10)
        end
      end
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
    str.should =~ %r{fill:black}
  end

  it "should group styles override nesting" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      with_style :stroke_width=>3 do
        with_style :stroke_width=>5 do
          circle(0, 0, 10)
        end
      end
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:5}
  end

  it "should group styles limited effect" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      with_style :stroke_width=>3 do
        with_style :stroke_width=>5 do
        end
      end
      circle(0, 0, 10)
    end
    str = img.output
    str.should_not =~ %r{stroke-width:3}
    str.should_not =~ %r{stroke-width:5}
  end
  
  it "should create a group" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      group :stroke_width=>3 do
        circle(0, 0, 10)
        circle(20, 20, 10)
      end
    end
    str = img.output
    str.should =~ %r{<g .*circle.*circle.*</g>}
  end

  it "should apply transforms to a group" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      group({}, {:scale => 5, :translate => [15,20]}) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{scale\(5\)translate\(15,20\)}
  end
  
  it "should update width and height after init" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      set_width 200
      set_height 300
    end
    str = img.output
    str.should =~ %r{width="200"}
    str.should =~ %r{height="300"}
  end

  it "should draw text" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      text 10, 20, "Hello world!"
    end
    str = img.output
    str.should =~ %r{<text}
    str.should =~ %r{x="10"}
    str.should =~ %r{y="20"}
    str.should =~ %r{Hello world!}
  end

  it "should draw multiline text" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      text 10, 20, "Hello\nworld!"
    end
    str = img.output
    str.should =~ %r{<text.*tspan.*tspan.*</text}
  end
  
  it "should draw text with font" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      text 10, 20, "Hello\nworld!", :font_family=>"Times", "font-size"=>24
    end
    str = img.output
    str.should =~ %r{font-family="Times"}
    str.should =~ %r{font-size="24"}
  end

  it "should include an image" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      image 10, 20, 30, 40, 'image.png'
    end
    str = img.output
    str.should =~ %r{<image}
    str.should =~ %r{x="10"}
    str.should =~ %r{y="20"}
    str.should =~ %r{width="30"}
    str.should =~ %r{height="40"}
    str.should =~ %r{xlink:href="image.png"}
  end

end
