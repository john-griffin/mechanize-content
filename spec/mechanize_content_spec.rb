# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MechanizeContent" do
  use_vcr_cassette :record => :new_episodes
  
  it "initialise mechanize content" do
    mc = MechanizeContent::Parser.new("http://www.google.com")
    mc.pages.first.url.should eql("http://www.google.com")
  end
  
  it "fetch the best title" do
    mc = MechanizeContent::Parser.new("http://techmeme.com/")
    mc.best_title.should eql("Techmeme")
  end
  
  it "page has incorrect class so only url returned" do
    p = MechanizeContent::Page.new("http://techmeme.com/")
    p.stub!(:agent => double("agent", :get => double("p")))
    MechanizeContent::Page.stub!(:new => p)
    mc = MechanizeContent::Parser.new("http://techmeme.com/")
    mc.best_title.should eql("http://techmeme.com/")
  end
  
  it "page has no title so only url returned" do
    p = mock("page", :title => nil, :url => "http://techmeme.com/")
    MechanizeContent::Page.stub!(:new => p)
    mc = MechanizeContent::Parser.new("http://techmeme.com/")
    mc.best_title.should eql("http://techmeme.com/")
  end
  
  it "page retrival errors" do
    mc = MechanizeContent::Page.new("http://techmeme.com/")
    mc2 = MechanizeContent::Page.new("http://somewherelse.com/")
    agent = mock("agent")
    page = mock("page")
    page.stub!(:class).and_return(Mechanize::Page)
    agent.should_receive(:get).with("http://techmeme.com/").and_raise(Timeout::Error)
    agent.should_receive(:get).with("http://somewherelse.com/").and_raise(Errno::ECONNRESET)
    mc.should_receive(:agent).any_number_of_times.and_return(agent)
    mc2.should_receive(:agent).any_number_of_times.and_return(agent)
    
    mc.fetch_content.should eql(nil)
    mc2.fetch_content.should eql(nil)
  end  
  
  it "mechanize page issues" do
    mc = MechanizeContent::Page.new("http://techmeme.com/")
    agent = mock("agent")
    page = mock("page")
    mc.stub!(:agent).and_return(agent)
    page.stub!(:code).and_return(400)
    agent.should_receive(:get).with("http://techmeme.com/").and_return(page)
    mc.fetch_content.should eql(nil)
  end
  
  it "fetch some text" do
    mc2 = MechanizeContent::Page.new("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
    mc2.text.should eql("Game Developers Conference organizers have confirmed the final set of independent game-specific content, including Ron Carmel on the just-debuted Indie Fund, the Gamma IV party/showcase, and the EGW-replacing Nuovo Sessions game showcase.The newly confirmed details round off a multitude of independent game-specific content at the March 9th-13th event, held at the Moscone Center in San Francisco, including the 12th Annual Independent Games Festival -- featuring over 30 top indie games playable on the GDC Expo floor from Thursday 11th to Saturday 13th, as well as the major IGF Awards on Thursday 11th at 6.30pm.In addition, the 4th Independent Games Summit on Tuesday 9th and Wednesday 10th has added and clarified a number of sessions, with 2D Boy's Ron Carmel kicking off the event with 'Indies and Publishers: Fixing a System That Never Worked', now confirmed to discuss the new Indie Fund organization.Another major new panel, 'Tripping The Art Fantastic', features Spelunky creator Derek Yu, Braid artist David Hellman and Super Meat Boy co-creator Edmund McMillen discussing \"how each one of these figures influences the state of game art, from hand painted epics to short form experimental Flash games.\"")
  end
  
  it "find the best text" do
    mc = MechanizeContent::Parser.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
    mc.best_text.should eql(nil)
    
    mc2 = MechanizeContent::Parser.new("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
    mc2.best_text.should eql("Game Developers Conference organizers have confirmed the final set of independent game-specific content, including Ron Carmel on the just-debuted Indie Fund, the Gamma IV party/showcase, and the EGW-replacing Nuovo Sessions game showcase.The newly confirmed details round off a multitude of independent game-specific content at the March 9th-13th event, held at the Moscone Center in San Francisco, including the 12th Annual Independent Games Festival -- featuring over 30 top indie games playable on the GDC Expo floor from Thursday 11th to Saturday 13th, as well as the major IGF Awards on Thursday 11th at 6.30pm.In addition, the 4th Independent Games Summit on Tuesday 9th and Wednesday 10th has added and clarified a number of sessions, with 2D Boy's Ron Carmel kicking off the event with 'Indies and Publishers: Fixing a System That Never Worked', now confirmed to discuss the new Indie Fund organization.Another major new panel, 'Tripping The Art Fantastic', features Spelunky creator Derek Yu, Braid artist David Hellman and Super Meat Boy co-creator Edmund McMillen discussing \"how each one of these figures influences the state of game art, from hand painted epics to short form experimental Flash games.\"")
  end
  
  it "reject all gifs" do
    img = {"src" => "http://www.cmpevents.com/GD10/ablank.gif2", "width" => 500, "height" => 500}
    image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
    image.should_not be_interesting_css    
  end
  
  it "reject image with banner in the name" do
    img = {"src" => "http://www.cmpevents.com/GD10/banner.png", "width" => 500, "height" => 500}
    image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
    image.should_not be_interesting_css    
  end
  
  it "reject image that is too small" do
    img = {"src" => "http://www.cmpevents.com/GD10/toosmall.png", "width" => 64, "height" => 500}
    image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
    image.should_not be_interesting_css
  end
  
  it "allow good images" do
    img = {"src" => "http://www.cmpevents.com/GD10/perfecto.png", "width" => 500, "height" => 500}
    image = MechanizeContent::Image.new(img, "https://www.cmpevents.com")
    image.should be_interesting_css
  end
  
  it "build a base url for images" do
    mc = MechanizeContent::Page.new("http://www.mutinydesign.co.uk/scripts/html-base-tag---1/")
    mc.base_url.to_s.should eql("http://www.mutinydesign.co.uk")
  end
  
  it "find image" do
    mc = MechanizeContent::Page.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html")
    mc.image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
    
    mc3 = MechanizeContent::Page.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
    mc3.image.should eql(nil)
    
    mc4 = MechanizeContent::Page.new("http://www.gog.com/page_has_no_content")
    mc4.stub!(:fetch_content).and_return(nil)
    mc4.image.should eql(nil)
    
    mc5 = MechanizeContent::Page.new("http://www.egmnow.com/press/time-warner-retail-egm.html")
    mc5.image.should eql("http://www.egmnow.com/images/egmlogo.jpg")
  end
  
  it "find the best image" do
    mc = MechanizeContent::Parser.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html")
    mc.best_image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
    
    mc3 = MechanizeContent::Parser.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
    mc3.best_image.should eql(nil)
  end
  
  it "can handle arrays" do
    mc = MechanizeContent::Parser.new(["http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html", "http://www.vg247.com/2010/03/18/gta-iv-episodes-from-liberty-city-sees-slight-delay-on-pc-and-ps3/"])
    mc.best_title.should eql("Street Crimes of L.A. Noire: New Screenshots & Info | Rockstar Games")
    mc.best_text.should eql(" Two women describe their encounter with a pervert to Detective Phelps in \"Camera Obscura\", one of many street crimes you'll encounter while exploring the city in L.A. Noire.\rIn addition to all of the desk cases you'll tackle as Cole Phelps as part of the main story of L.A. Noire, you'll also have the opportunity to bring wayward miscreants to justice and protect and serve the city of Los Angeles by solving Street Crimes. Pay attention to your police radio as you're driving around the city of L.A., requests for help will be broadcast to your squad car, and an icon will appear on your map. More and more Street Crimes will become unlocked as you progress through the game, solving them all will earn you 'The Long Arm of the Law' Achievement/Trophy.\rCheck out new screens from just a few of the incidents you'll encounter on the streets of Los Angeles below, which can also be seen in high definition at the official L.A. Noire site Screenshots section.\r A pair of novice criminals attempt to pull off a jewelry store heist in \"Amateur Hour.\"\r Chase down the armed suspects responsible for shooting this patrol officer in the \"Cop Killer Shot\" case.\r Phelps and Bekowsky encounter a man on the sidewalk that been robbed of everything - even his footwear - in the \"Shoo-Shoo Bandits\" Street Crimes case.\rPreviously:L.A. Noire Character Dossier & New Screens: Mickey CohenScreens from L.A. Noire Crime Desk #4 of 5: ViceCandy Edwards - L.A. Noire Character Dossier & New Screens")
    mc.best_image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
  end
  
  it "find the best content from multiple urls" do
    mc = MechanizeContent::Parser.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html", "http://www.vg247.com/2010/03/18/gta-iv-episodes-from-liberty-city-sees-slight-delay-on-pc-and-ps3/")
    mc.best_title.should eql("Street Crimes of L.A. Noire: New Screenshots & Info | Rockstar Games")
    mc.best_text.should eql(" Two women describe their encounter with a pervert to Detective Phelps in \"Camera Obscura\", one of many street crimes you'll encounter while exploring the city in L.A. Noire.\rIn addition to all of the desk cases you'll tackle as Cole Phelps as part of the main story of L.A. Noire, you'll also have the opportunity to bring wayward miscreants to justice and protect and serve the city of Los Angeles by solving Street Crimes. Pay attention to your police radio as you're driving around the city of L.A., requests for help will be broadcast to your squad car, and an icon will appear on your map. More and more Street Crimes will become unlocked as you progress through the game, solving them all will earn you 'The Long Arm of the Law' Achievement/Trophy.\rCheck out new screens from just a few of the incidents you'll encounter on the streets of Los Angeles below, which can also be seen in high definition at the official L.A. Noire site Screenshots section.\r A pair of novice criminals attempt to pull off a jewelry store heist in \"Amateur Hour.\"\r Chase down the armed suspects responsible for shooting this patrol officer in the \"Cop Killer Shot\" case.\r Phelps and Bekowsky encounter a man on the sidewalk that been robbed of everything - even his footwear - in the \"Shoo-Shoo Bandits\" Street Crimes case.\rPreviously:L.A. Noire Character Dossier & New Screens: Mickey CohenScreens from L.A. Noire Crime Desk #4 of 5: ViceCandy Edwards - L.A. Noire Character Dossier & New Screens")
    mc.best_image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
    
    mc = MechanizeContent::Parser.new("http://www.facebook.com/RockBand", "http://www.vg247.com/2010/03/09/rock-band-3-out-this-holiday-will-revolutionize-genre/")
    mc.best_title.should eql("Rock Band | Facebook")
    mc.best_text.should include("Harmonix just confirmed that Rock Band 3 will release this holiday season.Said the firm on Rock Band’s Facebook page:“Harmonix is developing Rock Band 3 for worldwide release this holiday season! The game, which will be published by MTV Games and distributed by Electronic Arts, will innovate and revolutionize the music genre once again, just as Harmonix did with the original Rock Band, Rock Band 2 and The Beatles: Rock Band. Stay tuned for more details!”There’s no more detail right now, but keep watching for updates from GDC.")
    mc.best_image.should eql("http://assets.vg247.com/current//2010/03/rockbandlogo.jpg")
  end
  
  it "gog link no text" do
    mc = MechanizeContent::Parser.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition", "http://www.destructoid.com/-nuff-said-good-old-games-gets-another-world-168150.phtml", "http://www.joystiq.com/2010/03/18/another-world-15th-anniversary-edition-now-on-gog-com/")
    mc.best_title.should eql("Another World: 15th Anniversary Edition - GOG.com")
    mc.best_text.should eql("Éric Chahi masterpiece is looking better than ever\r\r\rPosted on 2010-03-18 09:46:36 by \r\rEclipse:\r\rThe first time I've ever played Another World was on my 486, I remember I booted up the game and wow, I was so shocked at how &quot;cinematic&quot; it felt, it looked and played like an animated sci-fi movie, fluid animations, always unique enemies, action puzzles... I remember it was the first game I've ever played that needed you to actually run away from the beast atread more\r the end of the first level instead of just shooting the hell out of your enemies. The world around Lester felt more alive than every game I've ever played before and Lester himself was a true human, not some sort of pumped superdude with a shotgun.Smooth animations like I was never able to see from Prince of Persia times, glorious and fascinating graphics, rapid action sequences and an hard yet satisfying gameplay.When I played this remade version for the first time I had a similar feeling, It wasn't something new, I've played this game dozen of times during years, but the sharp vector graphics i was able too see as child on my old crt monitor looked pixelly on my new 23&quot; LCD, this restyle reminds me more than the original version how I used to look at this game, I know it may sound strange but it's true.And yay, no more passwords to remember :)This game made my childhood and it's one of the best games EVER.\r\r\r\rWas this helpful?\r\r\r(105 of 119 people found this helpful)")
  end
  
  it "getting wrong blurb from detructoid" do
    mc = MechanizeContent::Parser.new("http://www.destructoid.com/-nuff-said-good-old-games-gets-another-world-168150.phtml")
    mc.best_title.should eql("'Nuff said: Good Old Games gets Another World- Destructoid")
    mc.best_text.should eql("Another World -- or Out of this World, as many of you will know it by -- is now on DRM-free digital distribution service Good Old Games. It can be had for $9.99. Need I say more?\rI love the game, even though I have never made it more than oh, five minutes in. It's more or less universally loved by the Destructoid staff. Not long after we got an email detailing the good news, the thread soon reached fifteen or so replies full of praise for the game.\rOther, less exciting recent releases include: Empire Earth II Gold, Gabriel Knight 3, and Aquanox. Not to completely s**t on these games, but this is Another World we're talking about here.")
    mc.best_image.should eql(nil)
  end
  
  it "get this flash site to return nil for a title" do
    mc = MechanizeContent::Parser.new("http://www.sonypictures.co.uk/movies/cloudywithachanceofmeatballs/")
    mc.best_text.should eql(nil)
  end
  
end
