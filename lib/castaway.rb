class Castaway
  attr_accessor :castawayId, :name, :relatedLinks, :gender, :occupations

  #def initialize(id,name, relatedLinks, gender)
  #  @castawayId=id
  #  @name=name
  #  @relatedLinks=relatedLinks
  #  @gender=gender
  #end

  def self.validateString(string)
    string.strip!
    valid=true
    if string.include? "," or string == "" or string.include? "#" or string.include? "&" or string.include? ";"
      valid = false
    end
    valid
  end
end
