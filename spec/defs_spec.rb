require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGTagWithParent do

  it "should get a reference to the main image object" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100)
    l = img.line(0, 0, 100, 100)

    (l.img == img).should == true
  end


  it "should propagate the reference to the main image object" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100)
    l = img.group.group.line(0, 0, 100, 100)

    (l.img == img).should == true
  end


end


describe Rasem::SVGImage do

  it "should create a defs section" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      defs do
        group(:id => "group1") do
          circle(0, 0, 20)
        end
      end
    end
 
    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<g[^>]*id="group1">.*<circle[^>]*/></g>.*</defs>.*</svg>}
  end


  it "should also create a defs section" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      def_group("group1") do
        circle(0, 0, 20)
      end
    end
 
    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<g[^>]*id="group1">.*<circle[^>]*/></g>.*</defs>.*</svg>}
  end


  it "should update the existing definition" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      def_group("group1") do
        circle(0, 0, 20)
      end

      def_group("group1", :update) do
        circle(0, 0, 40)
      end

    end
 
    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<g[^>]*id="group1">.*<circle cx="0" cy="0" r="40"[^>]*/></g>.*</defs>.*</svg>}
  end


  it "should skip the new definition" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      def_group("group1") do
        circle(0, 0, 20)
      end

      def_group("group1") do
        circle(0, 0, 40)
        fail "should skip the block execution"
      end

      def_group("group1", :skip) do
        circle(0, 0, 40)
        fail "should skip the block execution"
      end

    end
 
    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<g[^>]*id="group1">.*<circle cx="0" cy="0" r="20"[^>]*/></g>.*</defs>.*</svg>}
  end


  it "should fail with the new definition" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100)
    img.def_group("group1") do
      circle(0, 0, 20)
    end

    expect{img.def_group("group1", :fail) do
      circle(0, 0, 40)
    end}.to raise_error

    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<g[^>]*id="group1">.*<circle cx="0" cy="0" r="20"[^>]*/></g>.*</defs>.*</svg>}
  end


end

