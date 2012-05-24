require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'timeout'
require_relative 'csv_processor.rb'
require_relative 'db_processor.rb'
require_relative 'castaway.rb'
#require_relative 'episode.rb'
#require_relative 'song.rb' 
#require_relative 'book.rb'
#require_relative 'luxury.rb'

class Collector
  attr_accessor :base_url, :names, :wikipediaLinks, :notOnWikiNames, :searchedNames

  def initialize
    @names = []
    @wikipediaLinks = []
    @notOnWikiNames = []
    @searchedNames = []
    @base_url="http://www.bbc.co.uk"
    #DbProcessor.create_db
  end

  def read_page controller, url

    individualLinks = []
    listOfNames = []
    page_response = Net::HTTP.get_response(URI(url)).body
    document_response = Nokogiri::HTML page_response
    individualLinks = document_response.xpath("//div[@class='text grid_28 fl_right']/h4/a/@href")
    listOfNames = document_response.xpath("//div[@class='text grid_28 fl_right']/h4/a/text()")
    for link in individualLinks
      controller.read_individual_link(@base_url+link)
    end
  end

  def read_individual_link url

    occupations = []
    page_response = Net::HTTP.get_response(URI(url)).body
    guest_doc = Nokogiri::HTML page_response
    name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()").to_s
    wikipediaLink = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/@href")
    wikipediaLinkDescription = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/text()")
    occupations = guest_doc.xpath("//div[@id='castaway_occupations']/div/div/p/a/text()")
    if !@names.include? name
      @names.push(name)
      if !wikipediaLinkDescription.to_s.capitalize.include? "Wikipedia"
        test_wikipedia(name)
      else
        puts "DID: #{wikipediaLink}"
        @wikipediaLinks.push(wikipediaLink)
      end


=begin
      person = Castaway.new(name, wikipediaLink, occupations, "Not av.");
      @songs=[]
      @songs=person.getSongs(guest_doc)
      #person added. Now add episode(s)
=end
    end

    return
  end

  def test_wikipedia name

    searchName = name.gsub(" ", "_").to_s
    searchName = check_name_for_title(searchName)

    begin
      h = Net::HTTP.new('en.wikipedia.org', 80)
      h.read_timeout = nil
      url = URI.parse("http://en.wikipedia.org/wiki/"+searchName)
      test_response(h, searchName, url)
    rescue Timeout::Error
      puts " rescue goes HERE: "
      test_response(h, searchName, url)
    end

  end

  def check_name_for_title name
    titles = ["Dame_", "Sir_", "Baron_", "Baroness_", "Reverend_", "Professor_", "Dr_", "Rt_Hon_", "Rt._Hon._"]
    titles.each do |title|

      if (name.start_with? title)
        name.slice! title
      else
        if (name.end_with? "_MP") # memeber of Parliament
          name.slice! "_MP"
        end
      end
    end
    if name.include? "&amp;"
      name = name.gsub!("&amp;", "and").to_s
    end

    return name
  end

  def test_response(h, searchName, url)
    response = h.request(Net::HTTP::Get.new(url.request_uri))
    if (Integer(response.code)==404)
      puts "Searched #{url}"
      puts "code: #{response.code}"
      @searchedNames.push(searchName)
      @wikipediaLinks.push("NA")
      @notOnWikiNames.push(searchName)
    else
      puts "Found: #{url}"
      @wikipediaLinks.push(url)
    end

  end

  def runner controller, url
    for i in (1..145)
      controller.read_page(controller, url+i.to_s)
    end

    puts "Guests: "
    puts @names.length

    #write to CSV:
    for name in @names
    CsvProcessor.addNewRowToNamesCsv([name])
    end

    puts "Not on wiki names to CSV: "
    for name in @notOnWikiNames
      CsvProcessor.addNewRowToNACsv([name])
    end
    puts "LINKS to CSV: "
    for link in @wikipediaLinks
      CsvProcessor.addNewRowToLinkCsv([link])
    end

    puts "__________>>>"
  end
end


controller = Collector.new
#controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/a-z/d/page/")
controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/page/")
