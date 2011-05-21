require 'spec_helper'

describe MechanizeContent::Page do
  use_vcr_cassette "MechanizeContent", :record => :new_episodes
  
  describe "#base_url" do
    context "given a page" do
      it "will have a base url" do
        mc = MechanizeContent::Page.new("http://www.mutinydesign.co.uk/scripts/html-base-tag---1/")
        mc.base_url.to_s.should eql("http://www.mutinydesign.co.uk")
      end
    end
  end

  describe "#image" do
    context "given a page with content" do
      it "will find an image" do
        mc = MechanizeContent::Page.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html")
        mc.image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
      end
    end
    
    context "given a page with no image" do
      it "will not find an image" do
        mc3 = MechanizeContent::Page.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
        mc3.image.should eql(nil)
      end
    end
    
    context "given a page with no content" do
      it "will not find an image" do
        mc4 = MechanizeContent::Page.new("http://www.gog.com/page_has_no_content")
        mc4.stub!(:fetch_content).and_return(nil)
        mc4.image.should eql(nil)
      end
    end
    
    context "given a page with an image" do
      it "will find the image" do
        mc5 = MechanizeContent::Page.new("http://www.egmnow.com/press/time-warner-retail-egm.html")
        mc5.image.should eql("http://www.egmnow.com/images/egmlogo.jpg")
      end
    end
  end
    
  describe "#fetch_content" do
    context "given an error in fetching the page" do
      it "has no content" do
        mc2 = MechanizeContent::Page.new("http://somewherelse.com/")
        agent = mock("agent")
        page = mock("page")
        page.stub!(:class).and_return(Mechanize::Page)
        agent.should_receive(:get).with("http://somewherelse.com/").and_raise(Errno::ECONNRESET)
        mc2.should_receive(:agent).any_number_of_times.and_return(agent)
        mc2.fetch_content.should eql(nil)
      end
    end
    context "given the page timeouts" do
      it "has no content" do
        mc = MechanizeContent::Page.new("http://techmeme.com/")
        agent = mock("agent")
        page = mock("page")
        page.stub!(:class).and_return(Mechanize::Page)
        agent.should_receive(:get).with("http://techmeme.com/").and_raise(Timeout::Error)
        mc.should_receive(:agent).any_number_of_times.and_return(agent)
        mc.fetch_content.should eql(nil)
      end
    end
    context "given the page is not available" do
      it "has no content" do
        mc = MechanizeContent::Page.new("http://techmeme.com/")
        agent = mock("agent")
        page = mock("page")
        mc.stub!(:agent).and_return(agent)
        page.stub!(:code).and_return(400)
        agent.should_receive(:get).with("http://techmeme.com/").and_return(page)
        mc.fetch_content.should eql(nil)
      end
    end
  end
  
  describe "#text" do
    context "given a page with content" do
      it "will find some text" do
        mc2 = MechanizeContent::Page.new("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
        mc2.text.should eql("Game Developers Conference organizers have confirmed the final set of independent game-specific content, including Ron Carmel on the just-debuted Indie Fund, the Gamma IV party/showcase, and the EGW-replacing Nuovo Sessions game showcase.The newly confirmed details round off a multitude of independent game-specific content at the March 9th-13th event, held at the Moscone Center in San Francisco, including the 12th Annual Independent Games Festival -- featuring over 30 top indie games playable on the GDC Expo floor from Thursday 11th to Saturday 13th, as well as the major IGF Awards on Thursday 11th at 6.30pm.In addition, the 4th Independent Games Summit on Tuesday 9th and Wednesday 10th has added and clarified a number of sessions, with 2D Boy's Ron Carmel kicking off the event with 'Indies and Publishers: Fixing a System That Never Worked', now confirmed to discuss the new Indie Fund organization.Another major new panel, 'Tripping The Art Fantastic', features Spelunky creator Derek Yu, Braid artist David Hellman and Super Meat Boy co-creator Edmund McMillen discussing \"how each one of these figures influences the state of game art, from hand painted epics to short form experimental Flash games.\"")
      end
    end
  end
end