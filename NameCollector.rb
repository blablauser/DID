require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'csv'

# exports the lit of names out of the individual links
class NameCollector
	attr_accessor :base_url, :names
	def initialize
	   @names = []
	   @wikipediaLinks = []
	   @base_url="http://www.bbc.co.uk"

	end

	def read_page nameCollector,url
	#get the individual links, for every guest
	   links = []
	   page_response = Net::HTTP.get_response(URI(url)).body
	   guests_doc =  Nokogiri::HTML page_response
       links = guests_doc.xpath("//div[@class='text grid_28 fl_right']/h4/a/@href")
       for link in links
       		 nameCollector.guest_related_link(@base_url+link)       		 
       end
    end

	def guest_related_link url
	#parse every individual page
	
	   page_response = Net::HTTP.get_response(URI(url)).body
	   guest_doc =  Nokogiri::HTML page_response
	   name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()").to_s
       wikipediaLink = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/@href")	   
       wikipediaLinkName = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/text()")
       if !wikipediaLinkName.to_s.include? "Wikipedia"
       		 	wikipediaLink = "NA"
       end
       @wikipediaLinks.push(wikipediaLink)
       @names.push(name)
       return
	end
	
	
	def runner nameCollector,url
		#for i in (1..2)
	    #	nameCollector.read_page(nameCollector,url+i.to_s)
		#end
		@names= ["alina","miss sunshine","bla bla","Alina", "blabla", "bla bla"]
		puts "Number of guests: "
        puts @names.length
        puts "Number of different names:"
        
        #either one works just fine
        
        distinctNames=Hash[@names.group_by {|x| x}.map {|k,v| [k,v.count]}]  
        #distinctNames = @names.inject(Hash.new(0)) {|h,x| h[x]+=1;h}.to_a
        puts distinctNames.length
        #distinctLinks = @wikipediaLinks.inject(Hash.new(0)) {|h,x| h[x]+=1;h}.to_a
        distinctLinks=Hash[@wikipediaLinks.group_by {|x| x}.map {|k,v| [k,v.count]}]
        
        #write to CSV:
        for name in @names
            CSV.open("names.csv", "wb") do |file|
				file << names
			end
  		end
  			
        puts "Links:"
       # puts @wikipediaLinks
        puts "Nr of links: #{@wikipediaLinks.length}"
        puts "NA counts: #{@wikipediaLinks.count("NA")}"
        puts "Number of different links:"
        puts distinctLinks.length
        puts "__________>>>"
	end

end

nameCollector = NameCollector.new
nameCollector.runner(nameCollector,"http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/a-z/d/page/")
#nameCollector.runner(nameCollector,"http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/page/")
