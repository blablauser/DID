require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'timeout'
require_relative 'csv_processor.rb'
#require_relative 'db_processor.rb'
require_relative 'castaway.rb'
require_relative 'episode.rb'
#require_relative 'record.rb'
#require_relative 'book.rb'
#require_relative 'luxury.rb'

class Collector
  attr_accessor :base_url, :names, :wikipediaLinks, :notOnWikiNames, :searchedNames, :gender, :wikipediaLink

  def initialize
    @castaways_table = []
    @guests = []
    @wikipedia_links = []
    @names_not_on_wiki = []
    @searched_names = []
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
    @wikipedia_link = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/@href")
    wikipediaLinkDescription = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/text()")
    occupations = guest_doc.xpath("//div[@id='castaway_occupations']/div/div/p/a/text()")

    if !@castaways_table.include? name
      if !name.include? "&amp;"

        @castaways_table.push(name)
        person = Castaway.new()
        person.castawayId= @castaways_table.length
        person.name=name
        person.gender=@gender
        person.occupations= occupations.to_s # array of occupations

        dates_of_broadcast = guest_doc.xpath("//div[@class='castaway-broadcast grid_19 fl_right']/h2/text()")
        occupation_by_episode = guest_doc.xpath("//div[@class='castaway-broadcast grid_19 fl_right']/p[@class='description']/text()")
        song_titles= guest_doc.xpath("//p[@class='track_choice']/text()")
        song_artists= guest_doc.xpath("//div[@class='text']/h4/text()")
        song_artists_links = guest_doc.xpath("//div[@class='text']/h4/a/text()")
        song_composer= guest_doc.xpath("//p[@class='composer']/text()")
        favourite=guest_doc.xpath("//p[@class='track_keep']/strong/text()")

        if !wikipediaLinkDescription.to_s.capitalize.include? "Wikipedia"
          test_wikipedia(name)
        end
        @wikipedia_links.push(@wikipedia_link)
        person.relatedLinks=@wikipedia_link
        @guests.push(person)
      else
        puts "Pair guests. Values discarded."
      end
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
    return name
  end

  def test_response(h, searchName, url)
    response = h.request(Net::HTTP::Get.new(url.request_uri))
    if (Integer(response.code)==404)
      puts "Not found #{url}"
      @searched_names.push(searchName)
      @wikipedia_link="NA"
      @names_not_on_wiki.push(searchName)
    else
      @wikipedia_link=url
      puts "Found: #{url}"
    end
  end

  def runner controller, url
    @gender="female"
    for i in (1..41)
      controller.read_page(controller, url+"gender/female/page/"+i.to_s)
    end

    @gender="male"
    for i in (1..105)
      controller.read_page(controller, url+"gender/male/page/"+i.to_s)
    end

    puts "Guests: "
    puts @castaways_table.length
    puts @guests.length

    #write to CSV:
    for name in @castaways_table
      CsvProcessor.addNewRow([name], "Guests")
    end

    puts "Not on wiki names to CSV: "
    for name in @names_not_on_wiki
      CsvProcessor.addNewRow([name], "namesNotOnWIki")
    end
    puts "LINKS to CSV: "
    for link in @wikipedia_links
      CsvProcessor.addNewRow([link], "links")
    end

    puts "__________>>>"
  end
end


controller = Collector.new

#controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/a-z/d/page/")
#controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/page/")
controller.runner(controller, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/")
