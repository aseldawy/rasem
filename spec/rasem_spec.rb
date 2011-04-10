require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGImage do
  it "should initialize an empty image" do
    img = Rasem::SVGImage.new("", 100, 100)
    str = img.output
    str.should =~ %r{width="100"}
    str.should =~ %r{height="100"}
  end

  it "should close an image" do
    img = Rasem::SVGImage.new("", 100, 100)
    img.close
    str = img.output
    str.should =~ %r{</svg>}
  end

  it "should auto close an image with block" do
    img = Rasem::SVGImage.new("", 100, 100) do
    end
    img.should be_closed
  end
  
  it "should draw line using method" do
    img = Rasem::SVGImage.new("", 100, 100)
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
    img = Rasem::SVGImage.new("", 100, 100) do
      line(0, 0, 100, 100)
    end
    str = img.output
    str.should =~ %r{<line}
    str.should =~ %r{x1="0"}
    str.should =~ %r{y1="0"}
    str.should =~ %r{x2="100"}
    str.should =~ %r{y2="100"}
  end

  it "should draw a circle" do
    img = Rasem::SVGImage.new("", 100, 100) do
      circle(0, 0, 10)
    end
    str = img.output
    str.should =~ %r{<circle}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{r="10"}
  end
  
  it "should draw a rectangle" do
    img = Rasem::SVGImage.new("", 100, 100) do
      rectangle(0, 0, 100, 300)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
  end

  it "should draw a symmetric round-rectangle" do
    img = Rasem::SVGImage.new("", 100, 100) do
      rectangle(0, 0, 100, 300, 20)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
    str.should =~ %r{rx="20"}
    str.should =~ %r{ry="20"}
  end

  it "should draw a non-symmetric round-rectangle" do
    img = Rasem::SVGImage.new("", 100, 100) do
      rectangle(0, 0, 100, 300, 20, 5)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
    str.should =~ %r{rx="20"}
    str.should =~ %r{ry="5"}
  end
  
  it "should draw an ellipse" do
    img = Rasem::SVGImage.new("", 100, 100) do
      ellipse(0, 0, 100, 300)
    end
    str = img.output
    str.should =~ %r{<ellipse}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{rx="100"}
    str.should =~ %r{ry="300"}
  end

  it "should draw a polygon given an array of points" do
    img = Rasem::SVGImage.new("", 100, 100) do
      polygon([[0,0], [1,2], [3,4]])
    end
    str = img.output
    str.should =~ %r{<polygon}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should draw a polyline given an array of points" do
    img = Rasem::SVGImage.new("", 100, 100) do
      polyline([[0,0], [1,2], [3,4]])
    end
    str = img.output
    str.should =~ %r{<polyline}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

end
