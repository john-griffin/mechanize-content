module MechanizeContent
  class Image
    def initialize(images, base_url)
      @images, @base_url = images, base_url
    end
    
    def url
      @url ||= find_best_image
    end
    
    def find_best_image
      begin
        current_src = nil
        @images.each do |img|
          current_src = img["src"]
          if Util.valid_image?(img['width'].to_i, img['height'].to_i, current_src)
            return Util.build_absolute_url(current_src, @base_url)
          end
        end
        @images.each do |img|
          current_src = img["src"]
          current_src = Util.build_absolute_url(current_src, @base_url)
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
      # rescue 
      #   puts "There was a problem connecting - " + current_src
      end
    end
    
  end
end