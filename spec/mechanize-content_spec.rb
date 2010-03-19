require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MechanizeContent" do
  it "initialise mechanize content" do
    mc = MechanizeContent.new("http://www.google.com")
    mc.urls.first.should eql("http://www.google.com")
  end
  
  it "fetch the best title" do
    mc = MechanizeContent.new("http://techmeme.com/")
    mc.best_title.should eql("Techmeme")
  end
  
  it "page has incorrect class so only url returned" do
    mc = MechanizeContent.new("http://techmeme.com/")
    agent = mock("agent")
    page = mock("page")
    page.stub!(:class).and_return(String)
    agent.should_receive(:get).with("http://techmeme.com/").and_return(page)
    mc.should_receive(:init_agent).and_return(agent)
    mc.best_title.should eql("http://techmeme.com/")
  end
  
  it "page has no title so only url returned" do
    mc = MechanizeContent.new("http://techmeme.com/")
    agent = mock("agent")
    page = mock("page")
    page.stub!(:class).and_return(Mechanize::Page)
    page.stub!(:title).and_return(nil)
    agent.should_receive(:get).with("http://techmeme.com/").and_return(page)
    mc.should_receive(:init_agent).and_return(agent)
    mc.best_title.should eql("http://techmeme.com/")
  end
  
  it "page retrival errors" do
    mc = MechanizeContent.new("http://techmeme.com/")
    agent = mock("agent")
    page = mock("page")
    page.stub!(:class).and_return(Mechanize::Page)
    agent.should_receive(:get).with("http://techmeme.com/").and_raise(Timeout::Error)
    agent.should_receive(:get).with("http://somewherelse.com/").and_raise(Errno::ECONNRESET)
    mc.should_receive(:init_agent).any_number_of_times.and_return(agent)
    
    mc.fetch_page("http://techmeme.com/").should eql(nil)
    mc.fetch_page("http://somewherelse.com/").should eql(nil)
  end  
  
  it "mechanize page issues" do
    mc = MechanizeContent.new("http://techmeme.com/")
    agent = mock("agent")
    page = mock("page")
    mc.stub!(:init_agent).and_return(agent)
    page.stub!(:code).and_return(400)
    agent.should_receive(:get).with("http://techmeme.com/").and_return(page)
    mc.fetch_page("http://techmeme.com/").should eql(nil)
  end
  
  it "fetch some text" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    page = mc.fetch_page("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.fetch_text(page).should eql(nil)
    
    mc2 = MechanizeContent.new("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
    page = mc2.fetch_page("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
    mc2.fetch_text(page).should eql("Game Developers Conference organizers have confirmed the final set of independent game-specific content, including Ron Carmel on the just-debuted Indie Fund, the Gamma IV party/showcase, and the EGW-replacing Nuovo Sessions game showcase.The newly confirmed details round off a multitude of independent game-specific content at the March 9th-13th event, held at the Moscone Center in San Francisco, including the 12th Annual Independent Games Festival -- featuring over 30 top indie games playable on the GDC Expo floor from Thursday 11th to Saturday 13th, as well as the major IGF Awards on Thursday 11th at 6.30pm.In addition, the 4th Independent Games Summit on Tuesday 9th and Wednesday 10th has added and clarified a number of sessions, with 2D Boy's Ron Carmel kicking off the event with 'Indies and Publishers: Fixing a System That Never Worked', now confirmed to discuss the new Indie Fund organization.Another major new panel, 'Tripping The Art Fantastic', features Spelunky creator Derek Yu, Braid artist David Hellman and Super Meat Boy co-creator Edmund McMillen discussing \"how each one of these figures influences the state of game art, from hand painted epics to short form experimental Flash games.\"")
  end
  
  it "find the best text" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.best_text.should eql(nil)
    
    mc2 = MechanizeContent.new("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
    mc2.best_text.should eql("Game Developers Conference organizers have confirmed the final set of independent game-specific content, including Ron Carmel on the just-debuted Indie Fund, the Gamma IV party/showcase, and the EGW-replacing Nuovo Sessions game showcase.The newly confirmed details round off a multitude of independent game-specific content at the March 9th-13th event, held at the Moscone Center in San Francisco, including the 12th Annual Independent Games Festival -- featuring over 30 top indie games playable on the GDC Expo floor from Thursday 11th to Saturday 13th, as well as the major IGF Awards on Thursday 11th at 6.30pm.In addition, the 4th Independent Games Summit on Tuesday 9th and Wednesday 10th has added and clarified a number of sessions, with 2D Boy's Ron Carmel kicking off the event with 'Indies and Publishers: Fixing a System That Never Worked', now confirmed to discuss the new Indie Fund organization.Another major new panel, 'Tripping The Art Fantastic', features Spelunky creator Derek Yu, Braid artist David Hellman and Super Meat Boy co-creator Edmund McMillen discussing \"how each one of these figures influences the state of game art, from hand painted epics to short form experimental Flash games.\"")
  end
  
  it "reject all gifs" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.valid_image?(500, 500, "http://www.cmpevents.com/GD10/ablank.gif2").should eql(false)
  end
  
  it "reject image with banner in the name" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.valid_image?(500, 500, "http://www.cmpevents.com/GD10/banner.png").should eql(false)
  end
  
  it "reject image that is too small" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.valid_image?(64, 500, "http://www.cmpevents.com/GD10/toosmall.png").should eql(false)
  end
  
  it "allow good images" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.valid_image?(500, 500, "http://www.cmpevents.com/GD10/perfecto.png").should eql(true)
  end
  
  it "build a base url for images" do
    mc = MechanizeContent.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    page = mc.fetch_page("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.get_base_url(page.parser, page.uri).to_s.should eql("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    
    mc = MechanizeContent.new("http://www.mutinydesign.co.uk/scripts/html-base-tag---1/")
    page = mc.fetch_page("http://www.mutinydesign.co.uk/scripts/html-base-tag---1/")
    mc.get_base_url(page.parser, page.uri).to_s.should eql("http://www.mutinydesign.co.uk/")
  end
  
  it "find image" do
    mc = MechanizeContent.new("http://www.rockstargames.com/newswire/2010/03/18/4061/episodes_from_liberty_city_now_coming_to_playstation_3_and_pc_this_april")
    page = mc.fetch_page("http://www.rockstargames.com/newswire/2010/03/18/4061/episodes_from_liberty_city_now_coming_to_playstation_3_and_pc_this_april")
    mc.fetch_image(page).should eql("http://www.rockstargames.com/rockstar/local_data/US/img/news/eflc_luisjohnny.jpg")
    
    mc2 = MechanizeContent.new("http://www.joystiq.com/2010/03/18/xbox-360-gaining-usb-storage-support-in-2010-update/")
    page2 = mc2.fetch_page("http://www.joystiq.com/2010/03/18/xbox-360-gaining-usb-storage-support-in-2010-update/")
    mc2.fetch_image(page2).should eql("http://www.blogcdn.com/www.joystiq.com/media/2010/03/joystiq-xbox-usb-support-580.jpg")
    
    mc3 = MechanizeContent.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
    page3 = mc3.fetch_page("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
    mc3.fetch_image(page3).should eql(nil)
    
    mc4 = MechanizeContent.new("http://www.gog.com/page_has_no_content")
    page4 = mock("page")
    mc4.stub!(:fetch_content).with(page4).and_return(nil)
    mc4.fetch_image(page4).should eql(nil)
    
    mc5 = MechanizeContent.new("http://www.egmnow.com/press/time-warner-retail-egm.html")
    page5 = mc5.fetch_page("http://www.egmnow.com/press/time-warner-retail-egm.html")
    mc5.fetch_image(page5).should eql("http://www.egmnow.com/images/egmlogo.jpg")
  end
  
  it "find the best image" do
    mc = MechanizeContent.new("http://www.rockstargames.com/newswire/2010/03/18/4061/episodes_from_liberty_city_now_coming_to_playstation_3_and_pc_this_april")
    mc.best_image.should eql("http://www.rockstargames.com/rockstar/local_data/US/img/news/eflc_luisjohnny.jpg")
    
    mc3 = MechanizeContent.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
    mc3.best_image.should eql(nil)
  end
  
end
