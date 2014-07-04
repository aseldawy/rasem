require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGTag do

  it "should maintain compatibility with transformations given in attributes" do
    tag = Rasem::SVGTag.new("g", :translate => [5, 5], :scale => 2)
    tag.translate(10, 10)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"translate\(5\s*,5\)\s*scale\(2\)\s*translate\(10,\s*10\)}

  end

  it "should add a translate transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.translate(10, 10)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"translate\(10,\s*10\)}
  end

  it "should return the instance after translate call" do
    tag = Rasem::SVGTag.new("g")
    tag.translate(10, 10).should == tag
  end


  it "should add a scale transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.scale(10, 10)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"scale\(10,\s*10\)}
  end

  it "should return the instance after scale call" do
    tag = Rasem::SVGTag.new("g")
    tag.scale(10, 10).should == tag
  end


  it "should add a rotate transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.rotate(45, 0, 0)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"rotate\(45,\s*0,\s*0\)}
  end


  it "should only give angle for rotation unless both coordinate are specified" do
    tag = Rasem::SVGTag.new("g")
    tag.rotate(45, 0)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"rotate\(45\)}

    tag.rotate(45)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"rotate\(45\)}
  end


  it "should return the instance after rotate call" do
    tag = Rasem::SVGTag.new("g")
    tag.rotate(10, 10).should == tag
  end


  it "should add a skewX transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.skewX(45)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"skewX\(45\)}
  end

  it "should return the instance after skewX call" do
    tag = Rasem::SVGTag.new("g")
    tag.skewX(45).should == tag
  end


  it "should add a skewY transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.skewY(45)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"skewY\(45\)}
  end

  it "should return the instance after skewY call" do
    tag = Rasem::SVGTag.new("g")
    tag.skewY(45).should == tag
  end


  it "should add a matrix transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.matrix(1, 2, 3, 4, 5, 6)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"matrix\(1,\s*2,\s*3,\s*4,\s*5,\s*6\)}
  end

  it "should return the instance after matrix call" do
    tag = Rasem::SVGTag.new("g")
    tag.matrix(1, 2, 3, 4, 5, 6).should == tag
  end


  it "should combine transformation" do
    tag = Rasem::SVGTag.new("g")
    tag.translate(0, 0).scale(2, 1).rotate(45).skewX(3).skewY(4).matrix(1,1,1,1,1,1)

    str = ""
    tag.write(str)
    str.should =~ %r{.*transform=\"translate\(0,\s*0\)\s*scale\(2,\s*1\)\s*rotate\(45\)\s*skewX\(3\)\s*skewY\(4\)\s*matrix\(1, 1, 1, 1, 1, 1\)}
  end



end
