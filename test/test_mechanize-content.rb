require 'helper'

class TestMechanizeContent < Test::Unit::TestCase
  def test_initialise_mechanize_content
    mc = MechanizeContent.new("http://www.google.com")
    assert_equal("http://www.google.com", mc.urls.first)
  end
  
  def test_best_title
    mc = MechanizeContent.new("http://techmeme.com/")
    assert_equal("Techmeme", mc.best_title)
  end
end
