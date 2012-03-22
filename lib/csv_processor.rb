require 'csv'

class CsvProcessor
  def self.addNewRowToGuestCsv guest
    CSV.open("../db/guests.csv", "a") do |csv|
      csv << guest
    end
  end

  def self.addNewRowToMusicChoicesCsv guest
    CSV.open("../db/choices.csv", "a") do |csv|
      csv << guest
    end
  end

  def self.addNewRowToNamesCsv guest
    CSV.open("../db/names.csv", "a") do |csv|
      csv << guest
    end
  end

  def self.addNewRowToNACsv guest
    CSV.open("../db/na.csv", "a") do |csv|
      csv << guest
    end
  end
end
