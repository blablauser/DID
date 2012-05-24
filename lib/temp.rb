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

# exports the lit of names out of the individual links
class Collector
  attr_accessor :base_url, :names, :wikipediaLinks, :notOnWikiNames, :error

  def initialize
    @names = []
    @songs = []
    @wikipediaLinks = []
    @notOnWikiNames = []
    @searchedNames = []
    @base_url="http://www.bbc.co.uk"
    #DbProcessor.create_db
  end

  def read_page controller, url
    #get the individual links, for every guest, and the list of names
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
    #parse every individual page
    #occupations = []
    page_response = Net::HTTP.get_response(URI(url)).body
    guest_doc = Nokogiri::HTML page_response
    name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()").to_s
    wikipediaLink = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/@href")
    wikipediaLinkDescription = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/text()")
    #occupations = guest_doc.xpath("//div[@id='castaway_occupations']/div/div/p/a/text()")
    #search_name(name, wikipediaLink, wikipediaLinkDescription)
    @names.push(name)
  end

  def search_on_related_links (name, wikipediaLink, wikipediaLinkDescription)
    if !wikipediaLinkDescription.to_s.include? "Wikipedia"
      wikipediaLink = "NA"
      @notOnWikiNames.push(name)
    end
    @wikipediaLinks.push(wikipediaLink)
    #person = Castaway.new(name, wikipediaLink, occupations, "Not av.")

    return
  end

  def test_response(h, searchName, url)
    response = h.request(Net::HTTP::Get.new(url.request_uri))
    if (Integer(response.code)==404)
      #not on wiki
      @searchedNames.push(searchName)
      puts "body size: #{response.body.size}" # > 19000
      puts "code: #{response.code}" # != 404
      puts "guest not on wiki"

    end
  end

  def search_name name, wikipediaLink, wikipediaLinkDescription
    if !@names.include? name
      @names.push(name)
      search_on_related_links(name, wikipediaLink, wikipediaLinkDescription)
      #search wiki name:
      searchName = name.gsub!(" ", "_").to_s
      # check if it's a Dame or Sir
      if (searchName.start_with? "Dame_")
        searchName.slice! "Dame_"
      else
        if (searchName.start_with? "Sir_")
          searchName.slice! "Sir_"
        end
      end

      # req timeout code == 408
      puts "link: http://en.wikipedia.org/wiki/#{searchName}"
      begin
      # do whatever
      h = Net::HTTP.new('en.wikipedia.org', 80)
      h.read_timeout = nil
      url = URI.parse("http://en.wikipedia.org/wiki/"+searchName)
      test_response(h, searchName, url)
      rescue Timeout::Error
        puts " rescue goes HERE: "
         test_response(h, searchName, url)
      end

    end

    return
  end


  def runner controller, url
    for i in (1..1)
      controller.read_page(controller, url+i.to_s)
    end

    puts "Guests: "
    puts @names.length

    #either one works just fine
    #namesOnWiki=Hash[@names.group_by { |x| x }.map { |k, v| [k, v.count] }]
    #distinctNames = @names.inject(Hash.new(0)) {|h,x| h[x]+=1;h}.to_a
    #puts distinctNames.length
    #distinctLinks = @wikipediaLinks.inject(Hash.new(0)) {|h,x| h[x]+=1;h}.to_a
    #namesOffWiki=Hash[@names.group_by { |x| x }.map { |k, v| [k, v.count] }]

    #write to CSV:

    #CsvProcessor.addNewRowToNamesCsv(@names)

    for name in @names

      CsvProcessor.addNewRowToMusicChoicesCsv([name])
    end
    #CsvProcessor.addNewRowToNACsv(@notOnWikiNames)


    puts "__________>>>"
  end

end


controller = Collector.new
#controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/a-z/d/page/")
controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/page/")
