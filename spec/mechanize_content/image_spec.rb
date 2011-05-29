require 'spec_helper'

describe MechanizeContent::Image do
  use_vcr_cassette :record => :new_episodes
  
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
        img = {"src" => "http://media.giantbomb.com/uploads/8/82135/1655259-background_black_v3_middle.jpg", "width" => 500, "height" => 500}
        image = MechanizeContent::Image.new(img, "http://www.giantbomb.com/news/to-congress-from-sony-we-still-dont-know-who-hacked-us-dont-believe-credit-card-data-taken/3273/")
        image.should be_interesting_css
      end
    end
  end  
end
