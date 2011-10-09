module MechanizeContent
  class Image
    MIN_WIDTH  = 64
    MIN_HEIGHT = 64
    AD_WIDTH = 728
    AD_HEIGHT = 90

    def self.best_image(images, base_url)
      imgs = images.map{|i| Image.new(i, base_url)}
      top_image = imgs.select{|i| i.interesting_css?}.first || imgs.select{|i| i.interesting_file?}.first
      top_image.absolute_url if top_image
    end

    def initialize(image, base_url)
      @src      = URI.escape(image["src"])
      @width    = image["width"].to_i
      @height   = image["height"].to_i
      @base_url = base_url
    end

    def interesting_css?
      valid_image?(@width, @height)
    end

    def interesting_file?
      open(absolute_url, "rb") do |fh|
        is = ImageSize.new(fh.read)
        return valid_image?(is.width, is.height)
      end
    end

    def valid_image?(width, height)
      big_enough?(width, height) && not_advertising?(width, height) && allows_hotlinking?
    end

    def allows_hotlinking?
      begin
        open(absolute_url, "Referer" => "http://splitstate.com")
      rescue OpenURI::HTTPError, SocketError
        return false
      end
      true
    end

    def advertising?(width, height)
      @src.include?("banner") || @src.include?(".gif") || ((width == AD_WIDTH) && (height == AD_HEIGHT))
    end

    def not_advertising?(width, height)
      !advertising?(width, height)
    end

    def big_enough?(width, height)
      width > MIN_WIDTH && height > MIN_HEIGHT
    end

    def absolute_url
      URI.parse(@src).relative? ? (URI.parse(@base_url.to_s)+@src).to_s : @src
    end
  end
end