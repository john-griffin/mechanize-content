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
    MechanizeContent::Util.get_base_url(page.parser, page.uri).to_s.should eql("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    
    mc = MechanizeContent.new("http://www.mutinydesign.co.uk/scripts/html-base-tag---1/")
    page = mc.fetch_page("http://www.mutinydesign.co.uk/scripts/html-base-tag---1/")
    MechanizeContent::Util.get_base_url(page.parser, page.uri).to_s.should eql("http://www.mutinydesign.co.uk/")
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
  
  it "find the best content from multiple urls" do
    mc = MechanizeContent.new("http://www.rockstargames.com/newswire/2010/03/18/4061/episodes_from_liberty_city_now_coming_to_playstation_3_and_pc_this_april", "http://www.vg247.com/2010/03/18/gta-iv-episodes-from-liberty-city-sees-slight-delay-on-pc-and-ps3/")
    mc.best_title.should eql("Rockstar Games | Rockstar News Wire | Episodes from Liberty City Now Coming to PlayStation 3 and PC this April")
    mc.best_text.should eql("Due to a last minute game submission request from Sony Computer Entertainment Europe to edit some of the in-game Liberty City radio station, television, and internet content – we are forced to delay the worldwide release of Grand Theft Auto: Episodes from Liberty City for both PlayStation 3 and PC for an extra two weeks.\rThe new release date for Episodes from Liberty City - and the two downloadable episodes The Lost and Damned and The Ballad of Gay Tony - on those platforms is now April 13th in North America and April 16th in Europe.  This new date will enable us to rectify these changes for Sony Europe, and still allow for a level playing field for all of the Grand Theft Auto fans that have been waiting patiently for this release.  In the meantime, we’re moving full speed ahead towards the new game release date.  On that note – please be aware that the Grand Theft Auto IV PlayStation 3 leaderboards at Rockstar Games Social Club will be down for maintenance for one week starting March 22nd as we work on their re-launch in support of Episodes from Liberty City.\rBelow are answers to some additional questions that we know some of you may have…\rThose game changes sound pretty minor.  Why does the game have to be delayed a whole two weeks?\rUnfortunately, with each round of changes comes fully re-testing the game and a full re-submission to PlayStation.  This is the nature of the game submission process.  Believe us, if we could expedite the turnaround any sooner – we would.  We are dying to get this game in the hands of fans who’ve waited for it for so long in the first place.Why is content being edited just for the European release?  This doesn’t seem fair.\rThere are different regional requirements for content – whether dictated by ratings boards like the ESRB and BBFC or by SCEE – this is pretty standard in the world of entertainment.\rIf this content is only being edited for the PlayStation 3 release, and only in Europe… why does everyone in North America etc have to wait?  And why do PC players have to wait at all?\rThis was a tough decision but with a simultaneous release, everyone can experience multiplayer simultaneously, take part in online events together, be on level ground on leaderboards, etc. What about those Episodes from Liberty City PSN and GFWL Social Club multiplayer events you announced for April 2nd and 3rd?  \rThe first Episodes events for those systems will now be on April 16th and 17th.  We will most likely replace the originally scheduled early April events with one for another game.  Any requests?\rAny other questions, please feel to leave in the Comments area and we’ll do our best to answer.  While this sort of thing may be commonplace in the world of interactive entertainment, we know that game delays are as disappointing to you all as they are to us – and we thank all of our fans immensely for their patience and understanding.\rRockstar Games")
    mc.best_image.should eql("http://www.rockstargames.com/rockstar/local_data/US/img/news/eflc_luisjohnny.jpg")
    
    mc = MechanizeContent.new("http://www.facebook.com/RockBand", "http://www.vg247.com/2010/03/09/rock-band-3-out-this-holiday-will-revolutionize-genre/")
    mc.best_title.should eql("Rock Band | Facebook")
    mc.best_text.should eql("Harmonix just confirmed that Rock Band 3 will release this holiday season.Said the firm on Rock Band’s Facebook page:“Harmonix is developing Rock Band 3 for worldwide release this holiday season! The game, which will be published by MTV Games and distributed by Electronic Arts, will innovate and revolutionize the music genre once again, just as Harmonix did with the original Rock Band, Rock Band 2 and The Beatles: Rock Band. Stay tuned for more details!”There’s no more detail right now, but keep watching for updates from GDC.")
    mc.best_image.should eql("http://assets.vg247.com/current//2010/03/rockbandlogo.jpg")
  end
  
  it "gog link no text" do
    mc = MechanizeContent.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition", "http://www.destructoid.com/-nuff-said-good-old-games-gets-another-world-168150.phtml", "http://www.joystiq.com/2010/03/18/another-world-15th-anniversary-edition-now-on-gog-com/")
    mc.best_title.should eql("Another World: 15th Anniversary Edition - GOG.com")
    mc.best_text.should eql("Another World -- or Out of this World, as many of you will know it by -- is now on DRM-free digital distribution service Good Old Games. It can be had for $9.99. Need I say more?\rI love the game, even though I have never made it more than oh, five minutes in. It's more or less universally loved by the Destructoid staff. Not long after we got an email detailing the good news, the thread soon reached fifteen or so replies full of praise for the game.\rOther, less exciting recent releases include: Empire Earth II Gold, Gabriel Knight 3, and Aquanox. Not to completely s**t on these games, but this is Another World we're talking about here.")
    mc.best_image.should eql("http://www.blogcdn.com/www.joystiq.com/media/2010/03/anotherworldheaderimg580px223.jpg")
  end
  
  it "getting wrong blurb from detructoid" do
    mc = MechanizeContent.new("http://www.destructoid.com/-nuff-said-good-old-games-gets-another-world-168150.phtml")
    mc.best_title.should eql("Destructoid - 'Nuff said: Good Old Games gets Another World")
    mc.best_text.should eql("Another World -- or Out of this World, as many of you will know it by -- is now on DRM-free digital distribution service Good Old Games. It can be had for $9.99. Need I say more?\rI love the game, even though I have never made it more than oh, five minutes in. It's more or less universally loved by the Destructoid staff. Not long after we got an email detailing the good news, the thread soon reached fifteen or so replies full of praise for the game.\rOther, less exciting recent releases include: Empire Earth II Gold, Gabriel Knight 3, and Aquanox. Not to completely s**t on these games, but this is Another World we're talking about here.")
    mc.best_image.should eql(nil)
  end
  
  it "avoid using copy from flash sites" do
    mc = MechanizeContent.new("http://www.godofwar.com/spartansstandtall/")
    mc.best_text.should eql(nil)
  end
  
end
