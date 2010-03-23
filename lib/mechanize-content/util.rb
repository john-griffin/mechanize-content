class MechanizeContent

  class Util
    
    MIN_WIDTH  = 64
    MIN_HEIGHT = 64
    AD_WIDTH = 728
    AD_HEIGHT = 90
    
    def self.get_base_url(doc, url)
      base_url = doc.xpath("//base/@href").first
      if base_url.nil?
        return url
      else
        return base_url.value
      end
    end
    
    def self.build_absolute_url(current_src, url)
      if URI.parse(current_src).relative?
        current_src = (URI.parse(url.to_s)+current_src).to_s
      end
      current_src
    end
    
    def self.valid_image?(width, height, src)
      if width > MIN_WIDTH && height > MIN_HEIGHT && !src.include?("banner") && !src.include?(".gif")
        if (!(width == AD_WIDTH) && !(height == AD_HEIGHT))
          return true
        end
      end
      return false
    end
    
  end
  
end