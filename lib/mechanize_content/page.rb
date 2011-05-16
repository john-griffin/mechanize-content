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
      text = fetch_text
      return text unless text.nil? || text.empty?
    end
    
    def image
      image = fetch_image
      return image unless image.nil?
    end
    
    def fetch_text
      top_content = parse_content
      if top_content
        text = top_content.text.delete("\t").delete("\n").strip
        ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
        text = ic.iconv(text + ' ')[0..-2]
      else
        return nil
      end
    end
    
    def fetch_image
      top_content = parse_content
      if top_content
        return find_best_image(top_content.css('img'), Util.get_base_url(content.parser, content.uri))
      else
        return nil
      end
    end
    
    def find_best_image(all_images, url)
      begin
        current_src = nil
        all_images.each do |img|
          current_src = img["src"]
          if Util.valid_image?(img['width'].to_i, img['height'].to_i, current_src)
            return Util.build_absolute_url(current_src, url)
          end
        end
        all_images.each do |img|
          current_src = img["src"]
          current_src = Util.build_absolute_url(current_src, url)
          open(current_src, "rb") do |fh|
            is = ImageSize.new(fh.read)
            if Util.valid_image?(is.width, is.height, current_src)
              return current_src
            end
          end
        end
        return nil
      rescue Errno::ENOENT
        puts "No such file - " + current_src
      rescue 
        puts "There was a problem connecting - " + current_src
      end
    end
    
    def parse_content
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