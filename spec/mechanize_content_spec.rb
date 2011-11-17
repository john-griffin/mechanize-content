# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MechanizeContent" do
  use_vcr_cassette :record => :new_episodes

  describe "#best_title" do
    context "given a page with a title" do
      it "will be that title" do
        mc = MechanizeContent::Parser.new("http://techmeme.com/")
        mc.best_title.should eql("Techmeme")
      end
    end

    context "given the page has an incorrect class" do
      it "will be the url" do
        p = MechanizeContent::Page.new("http://techmeme.com/")
        p.stub!(:agent => double("agent", :get => double("p")))
        MechanizeContent::Page.stub!(:new => p)
        mc = MechanizeContent::Parser.new("http://techmeme.com/")
        mc.best_title.should eql("http://techmeme.com/")
      end
    end

    context "given page has no title" do
      it "will be the url" do
        p = mock("page", :title => nil, :url => "http://techmeme.com/")
        MechanizeContent::Page.stub!(:new => p)
        mc = MechanizeContent::Parser.new("http://techmeme.com/")
        mc.best_title.should eql("http://techmeme.com/")
      end
    end

    context "given multiple urls are passed in" do
      it "will find the best title" do
        mc = MechanizeContent::Parser.new("http://www.facebook.com/RockBand", "http://www.vg247.com/2010/03/09/rock-band-3-out-this-holiday-will-revolutionize-genre/")
        mc.best_title.should eql("Rock Band | Facebook")
      end
    end

  end

  describe "#best_text" do
    context "page with no text" do
      it "will be nil" do
        mc = MechanizeContent::Parser.new("https://www.cmpevents.com/GD10/a.asp?option=C&V=11&SessID=10601")
        mc.best_text.should eql(nil)
      end
    end

    context "given a page with text" do
      it "will be the text" do
        mc2 = MechanizeContent::Parser.new("http://www.gamesetwatch.com/2010/03/gdc_2010_rounds_off_indie_cove.php")
        mc2.best_text.should eql("Game Developers Conference organizers have confirmed the final set of independent game-specific content, including Ron Carmel on the just-debuted Indie Fund, the Gamma IV party/showcase, and the EGW-replacing Nuovo Sessions game showcase.The newly confirmed details round off a multitude of independent game-specific content at the March 9th-13th event, held at the Moscone Center in San Francisco, including the 12th Annual Independent Games Festival -- featuring over 30 top indie games playable on the GDC Expo floor from Thursday 11th to Saturday 13th, as well as the major IGF Awards on Thursday 11th at 6.30pm.In addition, the 4th Independent Games Summit on Tuesday 9th and Wednesday 10th has added and clarified a number of sessions, with 2D Boy's Ron Carmel kicking off the event with 'Indies and Publishers: Fixing a System That Never Worked', now confirmed to discuss the new Indie Fund organization.Another major new panel, 'Tripping The Art Fantastic', features Spelunky creator Derek Yu, Braid artist David Hellman and Super Meat Boy co-creator Edmund McMillen discussing \"how each one of these figures influences the state of game art, from hand painted epics to short form experimental Flash games.\"")
      end
    end

    context "given multiple urls are passed in" do
      it "will find the best text" do
        mc = MechanizeContent::Parser.new("http://www.facebook.com/RockBand", "http://www.vg247.com/2010/03/09/rock-band-3-out-this-holiday-will-revolutionize-genre/")
        mc.best_text.should include("Harmonix just confirmed that Rock Band 3 will release this holiday season.Said the firm on Rock Band’s Facebook page:“Harmonix is developing Rock Band 3 for worldwide release this holiday season! The game, which will be published by MTV Games and distributed by Electronic Arts, will innovate and revolutionize the music genre once again, just as Harmonix did with the original Rock Band, Rock Band 2 and The Beatles: Rock Band. Stay tuned for more details!”There’s no more detail right now, but keep watching for updates from GDC.")
      end
    end

    context "given the first link has no text" do
      it "will pull text from the next link" do
        mc = MechanizeContent::Parser.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition", "http://www.destructoid.com/-nuff-said-good-old-games-gets-another-world-168150.phtml", "http://www.joystiq.com/2010/03/18/another-world-15th-anniversary-edition-now-on-gog-com/")
        mc.best_text.should eql("Éric Chahi masterpiece is looking better than ever\r\r\rPosted on 2010-03-18 09:46:36 by \r\rEclipse:\r\rThe first time I've ever played Another World was on my 486, I remember I booted up the game and wow, I was so shocked at how &quot;cinematic&quot; it felt, it looked and played like an animated sci-fi movie, fluid animations, always unique enemies, action puzzles... I remember it was the first game I've ever played that needed you to actually run away from the beast atread more\r the end of the first level instead of just shooting the hell out of your enemies. The world around Lester felt more alive than every game I've ever played before and Lester himself was a true human, not some sort of pumped superdude with a shotgun.Smooth animations like I was never able to see from Prince of Persia times, glorious and fascinating graphics, rapid action sequences and an hard yet satisfying gameplay.When I played this remade version for the first time I had a similar feeling, It wasn't something new, I've played this game dozen of times during years, but the sharp vector graphics i was able too see as child on my old crt monitor looked pixelly on my new 23&quot; LCD, this restyle reminds me more than the original version how I used to look at this game, I know it may sound strange but it's true.And yay, no more passwords to remember :)This game made my childhood and it's one of the best games EVER.\r\r\r\rWas this helpful?\r\r\r(105 of 119 people found this helpful)")
      end
    end

    context "given a page with strange class names" do
      it "should still be able to find the text" do
        mc = MechanizeContent::Parser.new("http://www.destructoid.com/-nuff-said-good-old-games-gets-another-world-168150.phtml")
        mc.best_text.should eql("Another World -- or Out of this World, as many of you will know it by -- is now on DRM-free digital distribution service Good Old Games. It can be had for $9.99. Need I say more?\rI love the game, even though I have never made it more than oh, five minutes in. It's more or less universally loved by the Destructoid staff. Not long after we got an email detailing the good news, the thread soon reached fifteen or so replies full of praise for the game.\rOther, less exciting recent releases include: Empire Earth II Gold, Gabriel Knight 3, and Aquanox. Not to completely s**t on these games, but this is Another World we're talking about here.")
      end
    end

    context "given a flash marketing micro site" do
      it "will be nil" do
        mc = MechanizeContent::Parser.new("http://www.sonypictures.co.uk/movies/cloudywithachanceofmeatballs/")
        mc.best_text.should eql(nil)
      end
    end

    context "given a first page with text that is too short" do
      it "will pull text from the next suitable page" do
        mc = MechanizeContent::Parser.new("http://www.examiner.com/fps-in-national/playstation-network-up-japan-video-announcement-video",
                                          "http://www.vg247.com/2011/05/28/sony-brings-psn-back-online-in-japan/",
                                          "http://kotaku.com/5806527/oh-yeah--playstation-network-is-back-online-in-japan")
        mc.best_text.should eq("Sony has announced that it has brought PlayStation Network services back online in Japan.After announcing a phased restoration of PSN and Qriocity Services in Japan and Asian countries and regions including Taiwan, Singapore, Malaysia, Indonesia, and Thailand yesterday, the firm has released a video of Sony president Kaz Harai revealing the service being brought back online.It’s posted below. But he is speaking in Japanese and there are no subtitles – just so you know. Yesterday, Sony also announced its plans for increased security measures in the region, which will “strengthen [and] safeguard against unauthorized activity, and provide consumers with greater protection of their personal information.”As an additional measure, a Chief Information Security Officer was created at SNEI who will work to reinforce overall information security across the company’s network infrastructure.“I’d also like to send my sincere regret to customers in Japan and Asian countries and regions for the inconvenience these events have caused you,” said Hirai. “We are taking aggressive action including increasing security measures and working with respective authorities to address the concerns that were raised by this incident.“We are making consumer data protection a full-time, company wide commitment so that our customers can rest assured about enjoying their entertainment.”The first phase of restored services for these countries and regions will include:Sign-in for PlayStationNetwork and Qriocity services, including the resetting of passwordsRestoration of online game-play across PS3 and PSP‘Friends’ category on PS3, including Friends List, Chat Functionality, Trophy Comparison, etc.PlayStation HomeAccess to other network features on services such as torne.(Customers will not be able to download movies rented through PlayStation Network video download service because movies have expired as a result of PlayStation Network service being turned off since April 21 (JST).)Thanks, Examiner.    Related postsPlayStation Japan relief effort brings in $1.3 millionSeason One tester brings Tribbles to Star Trek OnlineSony Japan reveals Dress                                                                                                        2                                                        Posted in: Japan, PSN, Sony                Tags: kaz hirai, psn services")
      end
    end
  end

  describe "#best_image" do
    context "given a page with a suitable image" do
      it "will be the image url" do
        mc = MechanizeContent::Parser.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html")
        mc.best_image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
      end
    end

    context "given a page with no suitable images" do
      it "will be nil" do
        mc3 = MechanizeContent::Parser.new("http://www.gog.com/en/gamecard/another_world_15th_anniversary_edition")
        mc3.best_image.should eql(nil)
      end
    end

    context "given multiple urls are passed in" do
      it "will find the best image" do
        mc = MechanizeContent::Parser.new("http://www.facebook.com/RockBand", "http://www.vg247.com/2010/03/09/rock-band-3-out-this-holiday-will-revolutionize-genre/")
        mc.best_image.should eql("http://assets.vg247.com/current//2010/03/rockbandlogo.jpg")
      end
    end

    context "given a url with strange utf8 encoding" do
      it "will find the best image" do
        mc = MechanizeContent::Parser.new(%w(http://www.computerandvideogames.com/310643/news/lg-dedicated-gaming-handhelds-are-over/
                                                   http://www.destructoid.com/lg-age-of-dedicated-gaming-handhelds-is-over--205485.phtml))
        mc.best_image.should eql("http://cdn.medialib.computerandvideogames.com/screens/screenshot_259495_thumb_wide300.jpg")
      end
    end

    context "given the first pick does not support hot linking" do
      it "will fall back to the next image" do
        mc = MechanizeContent::Parser.new("http://www.andriasang.com/e/blog/2011/05/27/kojima_questions/",
                                          "http://www.joystiq.com/2011/05/27/kojima-something-big-planned-for-25th-metal-gear-anniversary-ne/",
                                          "http://www.giantbomb.com/news/hideo-kojima-smacks-down-rumors-spreads-disappointment-ahead-of-e3/3272/",
                                          "http://www.vg247.com/2011/05/27/kojima-no-mgs5-at-e3-ngp-project-isnt-mgs4-port/",
                                          "http://www.1up.com/news/kojima-planning-something-big-metal-gear-anniversary")
        mc.best_image.should == "http://media.giantbomb.com/uploads/0/91/233021-2368273836_4080f1e08e_o_middle.jpg"
      end
    end
  end

  describe "#best_image_iphone" do
    context "given a page with an iphone fav icon" do
      it "will be the image url" do
        mc = MechanizeContent::Parser.new("http://www.officialplaystationmagazine.co.uk/2011/11/16/historic-issue-65-cover-features-hideo-kojima/")
        mc.best_image_iphone.should eql("http://static.officialplaystationmagazine.co.uk/wp-content/themes/opm/style/images/icon/apple-touch-icon.png")
      end
    end

    context "given a page with an iphone fav icon" do
      it "will be the image url" do
        mc = MechanizeContent::Parser.new("http://www.eurogamer.net/articles/2011-11-17-oddword-strangers-wrath-hd-ps3-complete")
        mc.best_image_iphone.should eql("http://www.eurogamer.net/img/EurogamerPage/apple-touch-icon.png")
      end
    end

    context "given a page with no iphone icon" do
      it "will return the normal image url" do
        mc = MechanizeContent::Parser.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html")
        mc.best_image_iphone.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
      end
    end
  end

  describe ".initialize" do
    context "given an array of urls are passed in" do
      it "will still parse content" do
        mc = MechanizeContent::Parser.new(["http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html", "http://www.vg247.com/2010/03/18/gta-iv-episodes-from-liberty-city-sees-slight-delay-on-pc-and-ps3/"])
        mc.best_title.should eql("Street Crimes of L.A. Noire: New Screenshots & Info | Rockstar Games")
        mc.best_text.should eql(" Two women describe their encounter with a pervert to Detective Phelps in \"Camera Obscura\", one of many street crimes you'll encounter while exploring the city in L.A. Noire.\rIn addition to all of the desk cases you'll tackle as Cole Phelps as part of the main story of L.A. Noire, you'll also have the opportunity to bring wayward miscreants to justice and protect and serve the city of Los Angeles by solving Street Crimes. Pay attention to your police radio as you're driving around the city of L.A., requests for help will be broadcast to your squad car, and an icon will appear on your map. More and more Street Crimes will become unlocked as you progress through the game, solving them all will earn you 'The Long Arm of the Law' Achievement/Trophy.\rCheck out new screens from just a few of the incidents you'll encounter on the streets of Los Angeles below, which can also be seen in high definition at the official L.A. Noire site Screenshots section.\r A pair of novice criminals attempt to pull off a jewelry store heist in \"Amateur Hour.\"\r Chase down the armed suspects responsible for shooting this patrol officer in the \"Cop Killer Shot\" case.\r Phelps and Bekowsky encounter a man on the sidewalk that been robbed of everything - even his footwear - in the \"Shoo-Shoo Bandits\" Street Crimes case.\rPreviously:L.A. Noire Character Dossier & New Screens: Mickey CohenScreens from L.A. Noire Crime Desk #4 of 5: ViceCandy Edwards - L.A. Noire Character Dossier & New Screens")
        mc.best_image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
      end
    end

    context "given urls are passed in as seperate arguements" do
      it "will parse arguements" do
        mc = MechanizeContent::Parser.new("http://www.rockstargames.com/newswire/article/16021/street-crimes-of-la-noire-new-screenshots-info.html", "http://www.vg247.com/2010/03/18/gta-iv-episodes-from-liberty-city-sees-slight-delay-on-pc-and-ps3/")
        mc.best_title.should eql("Street Crimes of L.A. Noire: New Screenshots & Info | Rockstar Games")
        mc.best_text.should eql(" Two women describe their encounter with a pervert to Detective Phelps in \"Camera Obscura\", one of many street crimes you'll encounter while exploring the city in L.A. Noire.\rIn addition to all of the desk cases you'll tackle as Cole Phelps as part of the main story of L.A. Noire, you'll also have the opportunity to bring wayward miscreants to justice and protect and serve the city of Los Angeles by solving Street Crimes. Pay attention to your police radio as you're driving around the city of L.A., requests for help will be broadcast to your squad car, and an icon will appear on your map. More and more Street Crimes will become unlocked as you progress through the game, solving them all will earn you 'The Long Arm of the Law' Achievement/Trophy.\rCheck out new screens from just a few of the incidents you'll encounter on the streets of Los Angeles below, which can also be seen in high definition at the official L.A. Noire site Screenshots section.\r A pair of novice criminals attempt to pull off a jewelry store heist in \"Amateur Hour.\"\r Chase down the armed suspects responsible for shooting this patrol officer in the \"Cop Killer Shot\" case.\r Phelps and Bekowsky encounter a man on the sidewalk that been robbed of everything - even his footwear - in the \"Shoo-Shoo Bandits\" Street Crimes case.\rPreviously:L.A. Noire Character Dossier & New Screens: Mickey CohenScreens from L.A. Noire Crime Desk #4 of 5: ViceCandy Edwards - L.A. Noire Character Dossier & New Screens")
        mc.best_image.should eql("http://media.rockstargames.com/rockstargames/img/global/news/upload/lanoire_streetcrimes_cameraobscura.jpg")
      end
    end
  end
end
