require 'rubygems'
require 'mechanize'
require 'image_size'
require 'open-uri'
require 'mechanize_content/util'
require 'mechanize_content/page'

module MechanizeContent
  class Parser
    attr_accessor :pages
    
    def initialize(*args)
      @pages = *args.flatten.map{|url| Page.new(url)}
    end

    def best_title
      @pages.map{|page| page.title}.compact.first || @pages.first.url
    end

    def best_text
      @pages.map{|page| page.text}.compact.first
    end

    def best_image
      @pages.map{|page| page.image}.compact.first
    end
  end
end