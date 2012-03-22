class Book
  attr_accessor :bookTitle, :trackArtist, :trackComposer

  def initialize(trackTitle, trackArtist, trackComposer)
    @trackTitle = trackTitle
    @trackArtist = trackArtist
    @trackComposer = trackComposer
  end
end
