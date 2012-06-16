class Castaway
  attr_accessor :castawayId, :name, :relatedLinks, :gender, :occupations


  def self.validateString(string)
    string.strip!
    valid=true
    if string.include? "," or string == "" or string.include? "#" or string.include? "&" or string.include? ";"
      valid = false
    end
    valid
  end
end
