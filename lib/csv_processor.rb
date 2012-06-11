require 'csv'

class CsvProcessor
  def self.addNewRow guest,file
    CSV.open("../db/"+file+".csv","a") do |csv|
      csv << guest
    end
  end
end
