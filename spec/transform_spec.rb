require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGTag do

  it "should add a translate transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.translate(10, 10)
    tag.attributes[:transform].should =~ %r{translate\(10,\s*10\)}
  end

  it "should return the instance after translate call" do
    tag = Rasem::SVGTag.new("svg")
    tag.translate(10, 10).should == tag
  end


  it "should add a scale transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.scale(10, 10)
    tag.attributes[:transform].should =~ %r{scale\(10,\s*10\)}
  end

  it "should return the instance after scale call" do
    tag = Rasem::SVGTag.new("svg")
    tag.scale(10, 10).should == tag
  end


  it "should add a rotate transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.rotate(45, 0, 0)
    tag.attributes[:transform].should =~ %r{rotate\(45,\s*0,\s*0\)}
  end


  it "should only give angle for rotation unless both coordinate are specified" do
    tag = Rasem::SVGTag.new("svg")
    tag.rotate(45, 0)
    tag.attributes[:transform].should =~ %r{rotate\(45\)}
    tag.rotate(45)
    tag.attributes[:transform].should =~ %r{rotate\(45\)}
  end


  it "should return the instance after rotate call" do
    tag = Rasem::SVGTag.new("svg")
    tag.rotate(10, 10).should == tag
  end


  it "should add a skewX transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.skewX(45)
    tag.attributes[:transform].should =~ %r{skewX\(45\)}
  end

  it "should return the instance after skewX call" do
    tag = Rasem::SVGTag.new("svg")
    tag.skewX(45).should == tag
  end


  it "should add a skewY transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.skewY(45)
    tag.attributes[:transform].should =~ %r{skewY\(45\)}
  end

  it "should return the instance after skewY call" do
    tag = Rasem::SVGTag.new("svg")
    tag.skewY(45).should == tag
  end


  it "should add a matrix transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.matrix(1, 2, 3, 4, 5, 6)
    tag.attributes[:transform].should =~ %r{matrix\(1,\s*2,\s*3,\s*4,\s*5,\s*6\)}
  end

  it "should return the instance after matrix call" do
    tag = Rasem::SVGTag.new("svg")
    tag.matrix(1, 2, 3, 4, 5, 6).should == tag
  end


  it "should combine transformation" do
    tag = Rasem::SVGTag.new("svg")
    tag.translate(0, 0).scale(2, 1).rotate(45).skewX(3).skewY(4).matrix(1,1,1,1,1,1)
    tag.attributes[:transform].should =~ %r{translate\(0,\s*0\)\s*scale\(2,\s*1\)\s*rotate\(45\)\s*skewX\(3\)\s*skewY\(4\)\s*matrix\(1, 1, 1, 1, 1, 1\)}
  end



end
