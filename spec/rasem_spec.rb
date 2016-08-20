require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGTag do
  it "should create an empty tag" do
    tag = Rasem::SVGTag.new("svg")
    str = ""
    tag.write(str)
    str.should =~ %r{<svg/>}
  end

  it "should create a tag with parameters" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    str = ""
    tag.write(str)
    str.should =~ %r{<svg width="100%" height="100%"/>}
  end

  it "should allow editing a parameter in existing tag" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    tag.height?.should == "100%"
    tag.height = "15%"
    tag.height?.should == "15%"
  end

  it "should raise errors if trying to reach invalid parameter" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    expect { tag.hight? }.to raise_error
    expect { tag.higgg = "10" }.to raise_error
  end

  it "should call spawn_child if possible to add that child" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    tag.should_receive('spawn_child').with(:g)
    tag.g
  end

  it "should not call spawn_child if not possible to add that child" do
    tag = Rasem::SVGTag.new("svg", :width=>"100%", :height=>"100%")
    tag.should_not_receive('spawn_child')
    expect { tag.ggr }.to raise_error
  end

  it "should create a child" do
    tag = Rasem::SVGTag.new("svg")
    tag.g
    str = ""
    tag.write(str)
    str.should =~ %r{<svg><g/></svg>}
  end

  it "should use alias for some children" do
    tag = Rasem::SVGTag.new("svg")
    tag.group
    str = ""
    tag.write(str)
    str.should =~ %r{<svg><g/></svg>}
  end

  it "should pass parameters to child" do
    tag = Rasem::SVGTag.new("svg")
    tag.group :id=>"G1", :class=>"C1"
    str = ""
    tag.write(str)
    str.should =~ %r{<svg><g id="G1" class="C1"/></svg>}
  end

  it "should raise an error when passing wrong parameter" do
    tag = Rasem::SVGTag.new("svg")
    expect { tag.group :height=>"100%" }.to raise_error
  end

  it "should allow passing non named parameters" do
    tag = Rasem::SVGTag.new("svg")
    tag.line 0, 0, 100, 100
    str = ""
    tag.write(str)
    str.should =~ %r{<svg><line x1="0" y1="0" x2="100" y2="100".*/></svg>}
  end

  it "should raise error when passing not enough non named parameters" do
    tag = Rasem::SVGTag.new("svg")
    expect { tag.line 0, 0, 100 }.to raise_error
  end

  it "should raise error when passing ill formed non named parameters (even if count matches)" do
    tag = Rasem::SVGTag.new("svg")
    expect { tag.line 0, 0, 100, :x2=>100 }.to raise_error
  end

  it "should raise error when passing too much non named parameters" do
    tag = Rasem::SVGTag.new("svg")
    expect { tag.line 0, 0, 100, 10, 10 }.to raise_error
  end

  it "should allow following non named parameters with named ones" do
    tag = Rasem::SVGTag.new("svg")
    tag.line 0, 0, 100, 100, :id=>"Line1"
    str = ""
    tag.write(str)
    str.should =~ %r{line}
    str.should =~ %r{x1="0"}
    str.should =~ %r{y1="0"} 
    str.should =~ %r{x2="100"}
    str.should =~ %r{y2="100"}
    str.should =~ %r{id="Line1"}
  end

  it "should use named parameters when there is a conflict" do
    tag = Rasem::SVGTag.new("svg")
    tag.line 0, 0, 100, 100, :x1=>"10"
    str = ""
    tag.write(str)
    str.should =~ %r{line}
    str.should =~ %r{x1="10"}
    str.should_not =~ %r{x1="0"} 
  end

  it "should insert a child from block within" do
    tag = Rasem::SVGTag.new("svg",:height=>"100%") do
      g :id=>"G1" do
      end
    end
    str = ""
    tag.write(str)
    str.should =~ %r{<svg height="100%"><g id="G1"/></svg>}
  end

  it "should nest easily" do
    tag = Rasem::SVGTag.new("svg") do
      g do
        g do
          g do
            g do
            end
          end
        end
      end
    end
    str = ""
    tag.write(str)
    str.should =~ %r{<svg><g><g><g><g/></g></g></g></svg>}
  end

  it "should add style element if parameters contain style tag" do
    tag = Rasem::SVGTag.new("svg") do
      line 0, 0, 10, 10, :stroke=>"violet"
    end
    str = ""
    tag.write(str)
    str.should =~ %r{style="stroke:violet;"}
  end

  it "should add transform element if parameters contain style tag" do
    tag = Rasem::SVGTag.new("svg") do
      line 0, 0, 10, 10, :scale=>2
    end
    str = ""
    tag.write(str)
    str.should =~ /transform=".*scale\(2\).*"/
  end
end

describe Rasem::SVGImage do
  it "should initialize an empty image" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    str = ""
    img.write(str)
    str.should =~ /<svg.*width="100".*height="100"/
  end

  it "should initialize an empty image in given output" do
    str = ""
    img = Rasem::SVGImage.new({:width=>"100", :height=>"100"}, str) do
    end
    str.should =~ /<svg.*width="100".*height="100"/
  end

  it "should initialize XML correctly" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    str = ""
    img.write(str)
    str.should =~ /^<\?xml/
  end

  it "should draw line using method" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100")
    img.line(0, 0, 100, 100)
    str = ""
    img.write(str)
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
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a circle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      circle(0, 0, 10)
    end
    str = ""
    img.write(str)

    str.should =~ %r{<circle}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{r="10"}
  end

  it "should draw a circle with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      circle(0, 0, 10, :fill=>"white")
    end
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a rectangle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 100, 300)
    end
    str = ""
    img.write(str)

    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
  end

  it "should draw a rectangle with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 10, 10, :fill=>"white")
    end
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a symmetric round-rectangle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 100, 300, 20)
    end
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a non-symmetric round-rectangle" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      rectangle(0, 0, 100, 300, 20, 5)
    end
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw an ellipse" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      ellipse(0, 0, 100, 300)
    end
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a polygon given an array of points" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      polygon([[0,0], [1,2], [3,4]])
    end
    str = ""
    img.write(str)

    str.should =~ %r{<polygon}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should draw a polygon with style" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      polygon([[0,0], [1,2], [3,4]], :fill=>"white")
    end
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a polyline given an array of points" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      polyline([[0,0], [1,2], [3,4]])
    end
    str = ""
    img.write(str)

    str.should =~ %r{<polyline}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should fix style names" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      circle(0, 0, 10, :stroke_width=>3)
    end
    str = ""
    img.write(str)

    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
  end

  it "should group styles" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      with_style :stroke_width=>3 do
        circle(0, 0, 10)
      end
    end
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

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
    str = ""
    img.write(str)

    str.should =~ %r{<g .*circle.*circle.*</g>}
  end

  it "should apply transforms to a group" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      group(:scale => 5, :translate => [15,20]) do
        circle(0, 0, 10)
      end
    end
    str = ""
    img.write(str)

    str.should =~ %r{scale\(5\)}
    str.should =~ %r{translate\(15,20\)}
  end

  it "should update width and height after init" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      self.width = 200
      self.height = 300
    end
    str = ""
    img.write(str)

    str.should =~ %r{width="200"}
    str.should =~ %r{height="300"}
  end

  it "should draw text" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      text 10, 20 do 
        raw "Hello world!"
      end
    end
    str = ""
    img.write(str)

    str.should =~ %r{<text}
    str.should =~ %r{x="10"}
    str.should =~ %r{y="20"}
    str.should =~ %r{Hello world!}
  end

#  it "should draw multiline text" do
#    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
#      text 10, 20 do
#        raw "Hello\nworld!"
#      end
#    end
#    str = ""
#    img.write(str)
#
#    str.should =~ %r{<text.*tspan.*tspan.*</text}
#  end

  it "should draw text with font" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      text 10, 20, "font-family"=>"Times", "font-size"=>24 do
        raw "Hello World"
      end
    end
    str = ""
    img.write(str)

    str.should =~ %r{font-family="Times"}
    str.should =~ %r{font-size="24"}
  end

  it "should include an image" do
    img = Rasem::SVGImage.new(:width=>"100", :height=>"100") do
      image 10, 20, 30, 40, 'image.png'
    end
    str = ""
    img.write(str)

    str.should =~ %r{<image}
    str.should =~ %r{x="10"}
    str.should =~ %r{y="20"}
    str.should =~ %r{width="30"}
    str.should =~ %r{height="40"}
    str.should =~ %r{xlink:href="image.png"}
  end

end
