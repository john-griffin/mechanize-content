# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mechanize-content}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Griffin"]
  s.date = %q{2010-03-23}
  s.description = %q{pass in a url or urls and mechanize-content will select the best block of text, image and title by analysing the page content}
  s.email = %q{johnog@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/mechanize-content.rb",
     "lib/mechanize-content/util.rb",
     "mechanize-content.gemspec",
     "spec/mechanize-content_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/john-griffin/mechanize-content}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{scrape the best content from a page}
  s.test_files = [
    "spec/mechanize-content_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mechanize>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<imagesize>, [">= 0.1.1"])
    else
      s.add_dependency(%q<mechanize>, [">= 1.0.0"])
      s.add_dependency(%q<imagesize>, [">= 0.1.1"])
    end
  else
    s.add_dependency(%q<mechanize>, [">= 1.0.0"])
    s.add_dependency(%q<imagesize>, [">= 0.1.1"])
  end
end

