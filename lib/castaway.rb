class Castaway
  attr_accessor :castawayId, :name, :relatedLinks, :occupations, :gender

  def initialize(name, relatedLinks, occupations, gender)
    @name=name
    @relatedLinks=relatedLinks
    @occupations=occupations
    @gender=gender
  end
  
  def getSongs guest_doc
  	
  return songs
  end

  def self.validateString(string)
    string.strip!
    valid=true
    if string.include? "," or string == "" or string.include? "#" or string.include? "&" or string.include? ";"
      valid = false
    end
    valid
  end
end
