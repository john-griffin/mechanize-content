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
  
end
