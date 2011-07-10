require "iconv"

module MechanizeContent
  class Util          
    def self.force_utf8(string)
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      ic.iconv(string.delete("\t").delete("\n").strip + ' ')[0..-2]
    end
  end
end