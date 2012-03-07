require 'rubygems'
require 'net/http'
require 'nokogiri'

# exports the lit of names out of the individual links
class NameCollector
	attr_accessor :base_url, :names
	def initialize
	   @names = []
	   @base_url="http://www.bbc.co.uk"

	end

	def read_page demo,url
	   links = []
	   page_response = Net::HTTP.get_response(URI(url)).body
	   guests_doc =  Nokogiri::HTML page_response
       links = guests_doc.xpath("//div[@class='text grid_28 fl_right']/h4/a/@href")
       for link in links
       		 name = demo.guest_name(@base_url+link)
       		 @names.push(name)
       end
       puts @names
	end

	def guest_name url
	   page_response = Net::HTTP.get_response(URI(url)).body
	   guest_doc =  Nokogiri::HTML page_response
       name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()")
       return name
	end

	def runner demo,url
		for i in (1..145)
	    	demo.read_page(demo,url+i.to_s)
		end
	end

end

demo = NameCollector.new
demo.runner(demo,"http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/page/")
