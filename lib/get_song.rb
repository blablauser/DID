# To change this template use File | Settings | File Templates.require 'rubygems'
require 'net/http'
require 'nokogiri'
require_relative 'csv_processor.rb'

# exports the lit of names out of the individual links
class GetSong
  attr_accessor :base_url, :names, :wikipediaLinks

  def initialize
    @names = []
    @guest = []
    @songs = []
    @wikipediaLinks = []
    @base_url="http://www.bbc.co.uk"

  end

  def read_page collector, url
    #get the individual links, for every guest
    links = []
    page_response = Net::HTTP.get_response(URI(url)).body
    guests_doc = Nokogiri::HTML page_response
    links = guests_doc.xpath("//div[@class='text grid_28 fl_right']/h4/a/@href")
    for link in links
      collector.guest_related_link(@base_url+link)
    end
  end

  def guest_related_link url
    #parse every individual page

    page_response = Net::HTTP.get_response(URI(url)).body
    guest_doc = Nokogiri::HTML page_response
    name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()").to_s
    artist1 = guest_doc.xpath("//div[@class='castaway-choice-row']/div/div/h4/text()")[0].to_s
    if artist1 == ''
      artist1 = guest_doc.xpath("//div[@class='castaway-choice-row']/div/div/h4/a/text()")[0].to_s
    end
    song1 = guest_doc.xpath("//p[@class='track_choice']/text()")[0].to_s

    puts "#{name} has : 1st choice: #{song1} by #{artist1} "
    @names.push(name)
    return
  end


  def runner collector, url

    collector.read_page(collector, url+1.to_s)


    puts "Number of guests: "
    puts @names.length
    puts "Number of different names:"

    #either one works just fine


    puts "__________>>>"
  end
end


collector = GetSong.new
collector.runner(collector, "http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/a-z/d/page/")
#collector.runner(collector,"http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/page/")

