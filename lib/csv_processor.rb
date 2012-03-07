require 'csv'

class CsvProcessor
  def self.addNewRowToCsv guest
      CSV.open("../db/names.csv", "a") do |csv|
		  csv <<  guest
      end
  end
end