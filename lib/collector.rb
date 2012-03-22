require 'rubygems'
require 'net/http'
require 'nokogiri'
require_relative 'csv_processor.rb'
#require_relative 'db_processor.rb'
#require_relative 'castaway.rb'
#require_relative 'episode.rb'
#require_relative 'song.rb' 
#require_relative 'book.rb'
#require_relative 'luxury.rb'

# exports the lit of names out of the individual links
class Collector
  attr_accessor :base_url, :names, :wikipediaLinks, :notOnWikiNames

  def initialize
    @names = []
    @wikipediaLinks = []
    @notOnWikiNames = []
    @base_url="http://www.bbc.co.uk"
  end

  def read_page collector, url
    #get the individual links, for every guest, and the list of names
    individualLinks = []
    listOfNames = []
    page_response = Net::HTTP.get_response(URI(url)).body
    document_response = Nokogiri::HTML page_response
    individualLinks = document_response.xpath("//div[@class='text grid_28 fl_right']/h4/a/@href")
    listOfNames = document_response.xpath("//div[@class='text grid_28 fl_right']/h4/a/text()")
    for link in individualLinks
      collector.read_individual_link(@base_url+link)
    end
  end

  def read_individual_link url
    #parse every individual page

    page_response = Net::HTTP.get_response(URI(url)).body
    guest_doc = Nokogiri::HTML page_response
    name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()").to_s
    wikipediaLink = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/@href")
    wikipediaLinkDescription = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/text()")

    if !@names.include? name
      @names.push(name)
      if !wikipediaLinkDescription.to_s.include? "Wikipedia"
        wikipediaLink = "NA"
        @notOnWikiNames.push(name)
      end
      @wikipediaLinks.push(wikipediaLink)
    end

    return
  end


  def runner collector, url
    for i in (1..2)
      collector.read_page(collector, url+i.to_s)
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

    puts "Not on wiki: "
    puts @notOnWikiNames
    #CsvProcessor.addNewRowToNACsv(@notOnWikiNames)


    puts "__________>>>"
  end
end


collector = Collector.new
collector.runner(collector, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/a-z/d/page/")
