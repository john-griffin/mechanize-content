# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mechanize_content/version"

Gem::Specification.new do |s|
  s.name        = "mechanize_content"
  s.version     = MechanizeContent::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Griffin"]
  s.email       = ["johnog@gmail.com"]
  s.homepage    = "http://github.com/john-griffin/mechanize-content"
  s.summary     = %q{scrape the best content from a page}
  s.description = %q{pass in a url or urls and mechanize-content will select the best block of text, image and title by analysing the page content}

  s.rubyforge_project = "mechanize_content"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency("mechanize", "~> 2.0.1")
  s.add_dependency("imagesize", "~> 0.1.1")
  s.add_development_dependency('rspec', "~> 2.6.0")
  s.add_development_dependency('vcr', "~> 1.11.3")
  s.add_development_dependency('fakeweb', "~> 1.3.0")
end
