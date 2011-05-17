module MechanizeContent
  class Page
    attr_accessor :url
    
    def initialize(url)
      @url = url
    end
    
    def title
      content.title if content
    end
    
    def text
      Util.force_utf8(best_content.text) if best_content
    end
    
    def image
      @image ||= best_content ? Image.best_image(images, base_url) : nil
    end
    
    def images
      best_content.css('img')
    end
    
    def base_url
      base = content.parser.xpath("//base/@href").first
      base ? base.value : content.uri
    end
        
    def best_content
      @best_content ||= find_content
    end
    
    def find_content
      return nil unless content
      doc = content.parser
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
        if !paragraph.parent.attributes.values.nil?
          if !paragraph.parent.attributes.values.first.nil?
            if paragraph.parent.attributes.values.first.value.include? "comment"
              break
            end
          end
        end
        readability[paragraph.parent] += paragraph.inner_text().count(',')
      end
      sorted_results = readability.sort_by { |parent,score| -score }
      if sorted_results.nil? || sorted_results.first.nil?
        return nil
      elsif !sorted_results.first.first.xpath("//a[@href='http://get.adobe.com/flashplayer/']").empty? || !sorted_results.first.first.xpath("//a[@href='http://www.adobe.com/go/getflashplayer']").empty?
        return nil
      else
        top_result = sorted_results.first.first
        top_result.css('script').unlink
        top_result.css('iframe').unlink
        top_result.css('h1').unlink
        top_result.css('h2').unlink
        return top_result
      end
    end
    
    
    def content
      @page_content ||= fetch_content
    end
    
    def fetch_content
      begin
        page_content = agent.get(@url)
        page_content if page_content.is_a?(Mechanize::Page)
      rescue Timeout::Error
        puts "Timeout - "+@url
      rescue Errno::ECONNRESET
        puts "Connection reset by peer - "+@url
      rescue Mechanize::ResponseCodeError
        puts "Invalid url"
      rescue Mechanize::UnsupportedSchemeError
        puts "Unsupported Scheme"
      rescue SocketError => e
        puts e
      # rescue
      #   puts "There was a problem connecting - "+@url
      end
    end
    
    def agent
      @agent ||= Mechanize.new {|a| a.user_agent_alias = 'Mac Safari'}
    end
    
  end
end