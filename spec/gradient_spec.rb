require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rasem::SVGLinearGradient do

  it "should create a linear gradient in the defs section" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      linearGradient("lgrad1") {}
    end

    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<linearGradient id="lgrad1"/>.*</defs></svg}
  end


  it "should support adding stops" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      linearGradient("lgrad1") do
        stop("0%", "green", 1)
        stop("100%", "blue", 1)
      end
    end

    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<linearGradient id="lgrad1">.*<stop offset="0%" stop-color="green" stop-opacity="1"/>.*<stop offset="100%" stop-color="blue" stop-opacity="1"/>.*</linearGradient>.*</defs></svg}
  end

end


describe Rasem::SVGRadialGradient do

  it "should create a radial gradient in the defs section" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      radialGradient("rgrad1") {}
    end

    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<radialGradient id="rgrad1"/>.*</defs></svg}
  end


  it "should support adding stops" do
    img = Rasem::SVGImage.new(:width => 100, :height => 100) do
      radialGradient("rgrad1") do
        stop("0%", "green", 1)
        stop("100%", "blue", 1)
      end
    end

    img.to_s.should =~ %r{.*<svg[^>]*>.*<defs>.*<radialGradient id="rgrad1">.*<stop offset="0%" stop-color="green" stop-opacity="1"/>.*<stop offset="100%" stop-color="blue" stop-opacity="1"/>.*</radialGradient.*</defs></svg}
  end



end

