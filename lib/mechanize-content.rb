require 'rubygems'
require 'mechanize'

class MechanizeContent
  
  attr_accessor :urls
  
  def initialize(*args)
    @urls = *args
  end
  
  def best_title
    @best_title || fetch_titles
  end
  
  def fetch_titles
    (@pages || fetch_pages).each do |page|
      title = page.title
      unless title.nil?
        ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
        title = ic.iconv(title + ' ')[0..-2]
        return @best_title = title
      end
      
    end
    return @urls.first
  end
  
  def fetch_pages
    @pages = []
    @urls.each do |url|
      page = fetch_page(url)
      @pages << page unless page.nil?
    end
    @pages
  end
  
  def fetch_page(url)
    begin
      page = (@agent || init_agent).get(url)
      if page.class ==  Mechanize::Page
        return page
      else
        return nil
      end
    rescue Timeout::Error
      puts "Timeout - "+url
    rescue Errno::ECONNRESET
      puts "Connection reset by peer - "+url
    rescue Mechanize::ResponseCodeError
      puts "Invalid url"
    rescue Mechanize::UnsupportedSchemeError
      puts "Unsupported Scheme"
    rescue
      puts "There was a problem connecting - "+url
    end
  end
  
  def init_agent
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    return @agent = agent
  end
end