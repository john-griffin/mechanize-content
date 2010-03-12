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
  
  def best_text
    @best_text || fetch_texts
  end
  
  def fetch_texts
    (@pages || fetch_pages).each do |page|
      text = fetch_text(page)
      return @best_text = text unless text.nil?
    end
    return nil
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
  
  def fetch_text(page)
    doc = page.parser
    readability = {}
    doc.css('p').each do |paragraph|
      if readability[paragraph.parent].nil?
        readability[paragraph.parent] = 0
      end
      parent_class = paragraph.parent['class'] || ""
      parent_id = paragraph.parent['id'] || ""
      if !parent_class.match('(comment|meta|footer|footnote)').nil?
        readability[paragraph.parent] -= 50
      elsif !parent_class.match('((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-_]?(content|text|body)?)(\\s|$))').nil?
        readability[paragraph.parent] += 25
      end
    
      if !parent_id.match('(comment|meta|footer|footnote)').nil?
        readability[paragraph.parent] -= 50
      elsif !parent_id.match('((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-_]?(content|text|body)?)(\\s|$))').nil?
        readability[paragraph.parent] += 25
      end
    
      if paragraph.inner_text().length > 10
        readability[paragraph.parent] += 1
      end
      readability[paragraph.parent] += paragraph.inner_text().count(',')
    end
    sorted_results = readability.sort_by { |parent,score| -score }
    if sorted_results.nil? || sorted_results.first.nil?
      return nil
    else
      top_result = sorted_results.first.first
      top_result.css('script').unlink
      top_result.css('iframe').unlink
      top_result.css('h1').unlink
      top_result.css('h2').unlink
      text = top_result.text.delete("\t").delete("\n").strip
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      text = ic.iconv(text + ' ')[0..-2]
      return text
    end
  end
  
end