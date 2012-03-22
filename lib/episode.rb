class Episode
  attr_accessor :episodeId, :castawayId, :dateOfBroadcast, :ageOfGuest, :occupationAtMomentOfBroadcast

  def initialize(castawayId, dateOfBroadcast, occupationAtMomentOfBroadcast, ageOfGuest)
    @castawayId=castawayId
    @dateOfBroadcast=dateOfBroadcast
    @occupationAtMomentOfBroadcast=occupations
    @ageOfGuest=ageOfGuest
  end

end
