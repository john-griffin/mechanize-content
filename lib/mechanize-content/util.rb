class MechanizeContent

  class Util
    
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
    
  end
  
end