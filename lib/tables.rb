class Record
  attr_accessor :recordId, :artist, :title, :composer, :genre, :label, :recording, :release

end

class RecordChoice
  attr_accessor :episodeId, :recordId, :choiceNumber, :favourite
end

class Luxury
  attr_accessor :luxuryId, :luxuryItem

end

class Episode
  attr_accessor :episodeId, :castawayId, :luxuryItemId, :dateOfBroadcast, :occupationOfGuest,    :ageOfGuest
end

class Castaway
  attr_accessor :castawayId, :name, :relatedLinks, :gender, :occupations, :linkFrom



  def self.validateString(string)
    string.strip!
    valid=true
    if string.include? "," or string == "" or string.include? "#" or string.include? "&" or string.include? ";"
      valid = false
    end
    valid
  end
end

class BookChoice
   attr_accessor :episodeId, :bookId
end

class Book
  attr_accessor :bookId, :bookAuthor, :bookTitle

end
