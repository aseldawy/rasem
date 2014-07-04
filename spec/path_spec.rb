require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGPath do

  it "should be an instance of SVGTag" do
    tag = Rasem::SVGPath.new
    (tag.class.superclass == Rasem::SVGTag).should == true
  end


  it "should create an empty path" do
    tag = Rasem::SVGPath.new
    tag.to_s.should =~ %r{<path d=\"\"\/>}
  end


  it "should add a move command" do
    tag = Rasem::SVGPath.new do
      moveTo(0, 0)
    end

    tag.to_s.should =~ %r{d=\"\s*m\s*0,0\"\/>}
  end


  it "should add an absolut move command" do
    tag = Rasem::SVGPath.new do
      moveToA(0, 0)
    end

    tag.to_s.should =~ %r{d=\"\s*M\s*0,0\"\/>}
  end


  it "should add a line command" do
    tag = Rasem::SVGPath.new do
      lineTo(0, 0)
    end

    tag.to_s.should =~ %r{d=\"\s*l\s*0,0\"\/>}
  end


  it "should add an absolut line command" do
    tag = Rasem::SVGPath.new do
      lineToA(0, 0)
    end

    tag.to_s.should =~ %r{d=\"\s*L\s*0,0\"\/>}
  end


  it "should add an horizontal line command" do
    tag = Rasem::SVGPath.new do
      hlineTo(0)
    end

    tag.to_s.should =~ %r{d=\"\s*h\s*0\"\/>}
  end


  it "should add an absolut horizontal line command" do
    tag = Rasem::SVGPath.new do
      hlineToA(0)
    end

    tag.to_s.should =~ %r{d=\"\s*H\s*0\"\/>}
  end


  it "should add an vertical line command" do
    tag = Rasem::SVGPath.new do
      vlineTo(0)
    end

    tag.to_s.should =~ %r{d=\"\s*v\s*0\"\/>}
  end


  it "should add an absolut vertical line command" do
    tag = Rasem::SVGPath.new do
      vlineToA(0)
    end

    tag.to_s.should =~ %r{d=\"\s*V\s*0\"\/>}
  end


  it "should add a curve command" do
    tag = Rasem::SVGPath.new do
      curveTo(10, 10, 0, 0, 5, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*c\s*0,0\s*5,5\s*10,10\"\/>}
  end


  it "should add an absolut curve command" do
    tag = Rasem::SVGPath.new do
      curveToA(10, 10, 0, 0, 5, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*C\s*0,0\s*5,5\s*10,10\"\/>}
  end


  it "should add a smooth curve command" do
    tag = Rasem::SVGPath.new do
      scurveTo(10, 10, 5, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*s\s*5,5\s*10,10\"\/>}
  end


  it "should add an absolut smooth curve command" do
    tag = Rasem::SVGPath.new do
      scurveToA(10, 10, 5, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*S\s*5,5\s*10,10\"\/>}
  end


  it "should add a quadratic curve command" do
    tag = Rasem::SVGPath.new do
      qcurveTo(10, 10, 5, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*q\s*5,5\s*10,10\"\/>}
  end


  it "should add an absolut quadratic curve command" do
    tag = Rasem::SVGPath.new do
      qcurveToA(10, 10, 5, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*Q\s*5,5\s*10,10\"\/>}
  end


  it "should add a smooth quadratic curve command" do
    tag = Rasem::SVGPath.new do
      sqcurveTo(10, 10)
    end

    tag.to_s.should =~ %r{d=\"\s*t\s*10,10\"\/>}
  end


  it "should add an absolut smooth quadratic curve command" do
    tag = Rasem::SVGPath.new do
      sqcurveToA(10, 10)
    end

    tag.to_s.should =~ %r{d=\"\s*T\s*10,10\"\/>}
  end


  it "should add an arc command" do
    tag = Rasem::SVGPath.new do
      arcTo(10, 10, 1, 2, 3, 4, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*a\s*1,2\s*3\s*4,5\s*10,10\"\/>}
  end


  it "should add an absolut arc command" do
    tag = Rasem::SVGPath.new do
      arcToA(10, 10, 1, 2, 3, 4, 5)
    end

    tag.to_s.should =~ %r{d=\"\s*A\s*1,2\s*3\s*4,5\s*10,10\"\/>}
  end


  it "should add a closepath command" do
    tag = Rasem::SVGPath.new do
      close
    end

    tag.to_s.should =~ %r{d=\"\s*Z\"\/>}
  end


  it "should allow to combine commands" do
    tag = Rasem::SVGPath.new do
      moveTo(0, 0)
      lineTo(0, 0)
      hlineTo(0)
      vlineTo(0)
      curveTo(10, 10, 0, 0, 5, 5)
      scurveTo(10, 10, 5, 5)
      qcurveTo(10, 10, 5, 5)
      sqcurveTo(10, 10)
      arcTo(10, 10, 1, 2, 3, 4, 5)
      close
    end

    tag.to_s.should =~ %r{d=\"\s*m\s*0,0\s*l\s*0,0\s*h\s*0\s*v\s*0\s*c\s*0,0\s*5,5\s*10,10\s*s\s*5,5\s*10,10\s*q\s*5,5\s*10,10\s*t\s*10,10\s*a\s*1,2\s*3\s*4,5\s*10,10\s*Z\s*\"}


    tag = Rasem::SVGPath.new do
      moveToA(0, 0)
      lineToA(0, 0)
      hlineToA(0)
      vlineToA(0)
      curveToA(10, 10, 0, 0, 5, 5)
      scurveToA(10, 10, 5, 5)
      qcurveToA(10, 10, 5, 5)
      sqcurveToA(10, 10)
      arcToA(10, 10, 1, 2, 3, 4, 5)
      close
    end

    tag.to_s.should =~ %r{d=\"\s*M\s*0,0\s*L\s*0,0\s*H\s*0\s*V\s*0\s*C\s*0,0\s*5,5\s*10,10\s*S\s*5,5\s*10,10\s*Q\s*5,5\s*10,10\s*T\s*10,10\s*A\s*1,2\s*3\s*4,5\s*10,10\s*Z\s*\"}

  end





end

