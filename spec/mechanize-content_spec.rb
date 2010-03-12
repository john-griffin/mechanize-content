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
  
end
