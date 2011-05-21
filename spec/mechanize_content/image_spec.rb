require 'spec_helper'

describe MechanizeContent::Image do
  describe "#interesting_css?" do
    context "given a gif" do
      it "is not interesting" do
        img = {"src" => "http://www.cmpevents.com/GD10/ablank.gif2", "width" => 500, "height" => 500}
        image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
        image.should_not be_interesting_css    
      end
    end
    
    context "given a banner" do
      it "is not interesting" do
        img = {"src" => "http://www.cmpevents.com/GD10/banner.png", "width" => 500, "height" => 500}
        image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
        image.should_not be_interesting_css    
      end
    end

    context "given a small image" do
      it "is not interesting" do
        img = {"src" => "http://www.cmpevents.com/GD10/toosmall.png", "width" => 64, "height" => 500}
        image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
        image.should_not be_interesting_css
      end
    end

    context "given a well sized non advertising image" do
      it "is valid" do
        img = {"src" => "http://www.cmpevents.com/GD10/perfecto.png", "width" => 500, "height" => 500}
        image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
        image.should be_interesting_css
      end
    end
  end  
end
