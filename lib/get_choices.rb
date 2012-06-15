require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'timeout'
require_relative 'csv_processor.rb'
require_relative 'tables.rb'
require_relative 'validate.rb'

class GetChoices
  attr_accessor :base_url, :castaways_table, :wikipedia_links, :names_not_on_wiki,
                :searched_names, :gender, :wikipediaLink, :episodes_table, :books_table,
                :luxury_table, :records_table, :record_choices_table, :book_choices_table

  def initialize
    @castaways_table = []
    @episodes_table = []
    @books_table = []
    @luxury_table = []
    @records_table = []
    @record_choices_table = []
    @guests = []
    @wikipedia_links = []
    @names_not_on_wiki = []
    @searched_names = []
    @book_choices_table = []
    @base_url="http://www.bbc.co.uk"

    #DbProcessor.create_db
  end

  def read_page controller, url

    individual_links = []
    list_of_names = []
    page_response = Net::HTTP.get_response(URI(url)).body
    document_response = Nokogiri::HTML page_response
    individual_links = document_response.xpath("//div[@class='text grid_28 fl_right']/h4/a/@href")
    list_of_names = document_response.xpath("//div[@class='text grid_28 fl_right']/h4/a/text()")

    for link in individual_links
      sleep(5)
      controller.read_individual_link(@base_url+link)
    end
  end


  def read_individual_link url

    page_response = Net::HTTP.get_response(URI(url)).body
    guest_doc = Nokogiri::HTML page_response
    name = guest_doc.xpath("//div[@id='castaway_intro']/h1/text()").to_s
    @wikipedia_link = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/@href")
    wikipedia_link_description = guest_doc.xpath("//div[@id='castaway_links']/div/div/p/a/text()").to_s.strip
    occupations = guest_doc.xpath("//div[@id='castaway_occupations']/div/div/p/a/text()").to_s.strip
    episodes = guest_doc.xpath("//div[@class='castaway-content']")

    if !@guests.include? name
      if !name.include? "&amp;"

        @guests.push(name)
        person = Castaway.new()
        person.castawayId= @castaways_table.length + 1
        person.name=name
        person.gender=@gender
        person.occupations= occupations.to_s # array of occupations

        if !wikipedia_link_description.capitalize.include? "Wikipedia"
          test_wikipedia(name)
        end
        @wikipedia_links.push(@wikipedia_link)
        person.relatedLinks=@wikipedia_link

        @castaways_table.push(person)
        puts "person"

        for episode in episodes
          parse_episode(episode, person)
        end

      else
        puts "Pair guests. Values discarded."
      end
    end

  end


  def parse_luxury(e, luxury_item)
    exists_item = @luxury_table.select { |item| item.luxuryItem == luxury_item }
    if exists_item.length != 0 # the item exists
      e.luxuryItemId = exists_item.at(0).luxuryId
    else
      # add the item
      item = Luxury.new
      item.luxuryId= @luxury_table.length + 1
      item.luxuryItem = luxury_item
      e.luxuryItemId = item.luxuryId
      @luxury_table.push(item)
    end
  end

  def parse_episode(episode, person)

    episode_doc = Nokogiri::XML (episode.to_s)
    date_of_broadcast = episode_doc.xpath("//div[@class='castaway-broadcast grid_19 fl_right']/h2/text()").to_s.strip
    occupation_by_episode = episode_doc.xpath("//div[@class='castaway-broadcast grid_19 fl_right']/p[@class='description']/text()").to_s.strip

    e = Episode.new
    e.dateOfBroadcast = date_of_broadcast
    e.occupationOfGuest= occupation_by_episode
    e.castawayId = person.castawayId
    # push it to @episodes_table after processing all choices.

    songs = episode_doc.xpath("//div[@class='text']")
    books = episode_doc.xpath("//h5[@class='book_choice']")

    luxury_item = episode_doc.xpath("//h5[@class='luxury_item_choice']/text()").to_s.strip

    luxury_item = Validate.check_for_hex_code(luxury_item).to_s
    luxury_item = Validate.capitalize_each luxury_item

    puts "#{luxury_item}"

    for song in songs
      parse_song(song)
    end

    #search for book
    books.each {|book|
      parse_book(book)
    }
    
    #search for luxury Item

    parse_luxury(e, luxury_item)

    @episodes_table.push(e)
    puts "#{@gender} episode from #{e.dateOfBroadcast}"
  end

  def parse_book(book)

    book_choice = BookChoice.new
    book_choice.episodeId = @episodes_table.length + 1

    book_doc = Nokogiri::XML (book.to_s)
    book_title = book_doc.xpath("//h5[@class='book_choice']/text()").to_s.strip
    book_title = Validate.check_for_hex_code(book_title)
    book_title = Validate.capitalize_each book_title

    if (book_title.end_with? " By")
          book_title.slice! " By"
    end

    book_author = book_doc.xpath("//h5[@class='book_choice']/span/text()").to_s.strip
    book_author = Validate.check_for_hex_code(book_author)
    book_author = Validate.capitalize_each book_author

    exists_book = @books_table.select { |book|
      ((book.bookTitle == book_title) || (book.bookTitle == "The "+book_title) || ("The "+book.bookTitle == book_title)) && (book.bookAuthor == book_author)
    }

    if exists_book.length == 0 # the book is not in the array
                               # add the book
      book = Book.new
      book.bookId= @books_table.length + 1
      book.bookTitle= book_title
      book.bookAuthor= book_author
      book_choice.bookId = book.bookId
      @books_table.push(book)
    else
      book_choice.bookId = exists_book.at(0).bookId
    end
    
    @book_choices_table.push(book_choice)
  end


  def parse_song(song)
    record_choice = RecordChoice.new
    record_choice.episodeId = @episodes_table.length + 1

    song_doc = Nokogiri::XML (song.to_s)

    song_choice_number = song_doc.xpath("//p[@class='number']/text()").to_s.strip
    record_choice.choiceNumber = song_choice_number

    song_artist= song_doc.xpath("//div[@class='text']/h4/text()").to_s.strip
    if song_artist == ''
      song_artist = song_doc.xpath("//div[@class='text']/h4/a/text()").to_s.strip
    end

    song_artist = Validate.check_for_hex_code(song_artist)
    song_artist = Validate.capitalize_each song_artist

    song_title= song_doc.xpath("//p[@class='track_choice']/text()").to_s.strip
    song_title = Validate.check_for_hex_code(song_title)
    song_title = Validate.capitalize_each song_title

    song_composer= song_doc.xpath("//p[@class='composer']/text()").to_s.strip
    song_composer = Validate.check_for_hex_code(song_composer)
    song_composer = Validate.capitalize_each song_composer

    favourite=song_doc.xpath("//p[@class='track_keep']/strong/text()").to_s.strip
    if favourite != ''
      record_choice.favourite = 1
    else
      record_choice.favourite = 0
    end

    #search song in the Records table
    # assume there is a unique combination of title+artist

    exists_record = @records_table.select { |record| (record.artist == song_artist) && (record.title == song_title) }
    if exists_record.length != 0 # the song is in the array
      if exists_record.length > 1
        puts " There is more than one combination artist + title"
      else
        record_choice.recordId = exists_record.at(0).recordId
      end
    else

      # the song does not exist in the table, thus must be added
      record = Record.new
      record.recordId = @records_table.length + 1
      record.artist = song_artist
      record.title = song_title
      record.composer = song_composer

      record_choice.recordId = record.recordId
      @records_table.push (record)
    end

    @record_choices_table.push (record_choice)

  end

  def test_wikipedia name

    search_name = name.gsub(" ", "_").to_s
    search_name = check_name_for_title(search_name)

    begin
      h = Net::HTTP.new('en.wikipedia.org', 80)
      h.read_timeout = nil
      url = URI.parse("http://en.wikipedia.org/wiki/"+search_name)
      test_response(h, search_name, url)
    rescue Timeout::Error
      puts " rescue goes HERE: "
      test_response(h, search_name, url)
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

  def test_response(h, search_name, url)
    response = h.request(Net::HTTP::Get.new(url.request_uri))
    if (Integer(response.code)==404)
      puts "Not found #{url}"
      @searched_names.push(search_name)
      @wikipedia_link="NA"
      @names_not_on_wiki.push(search_name)
    else
      @wikipedia_link=url
      puts "Found: #{url}"
    end
  end

  def output_results
    for x in @records_table
      CsvProcessor.addNewRow([x.recordId.to_s, x.artist.to_s, x.title.to_s, x.composer.to_s], "Records")
    end
    for x in @record_choices_table
      CsvProcessor.addNewRow([x.episodeId.to_s, x.recordId.to_s, x.choiceNumber.to_s, x.favourite.to_s], "RecordChoices")
    end
    for x in @book_choices_table
      CsvProcessor.addNewRow([x.episodeId.to_s, x.bookId.to_s], "BookChoices")
    end
    for x in @episodes_table #:episodeId, :castawayId, :bookId, :luxuryItemId, :dateOfBroadcast, :occupationOfGuest,
      CsvProcessor.addNewRow([x.episodeId.to_s, x.castawayId.to_s, x.luxuryItemId.to_s, x.dateOfBroadcast.to_s, x.occupationOfGuest.to_s], "Episodes")
    end
    for x in @castaways_table #castawayId, :name, :relatedLinks, :gender, :occupations
      CsvProcessor.addNewRow([x.castawayId.to_s, x.name.to_s, x.relatedLinks.to_s, x.gender.to_s, x.occupations.to_s], "Castaways")
    end
    for x in @books_table #bookId, :bookAuthor, :bookTitle
      CsvProcessor.addNewRow([x.bookId.to_s, x.bookAuthor.to_s, x.bookTitle.to_s], "Books")
    end
    for x in @luxury_table #:luxuryId, :luxuryItem
      CsvProcessor.addNewRow([x.luxuryId.to_s, x.luxuryItem.to_s], "LuxuryItems")
    end
  end

  def runner controller, url
    #@gender="female"
    #for i in (1..41)
    #  sleep(1)
    #  controller.read_page(controller, url+"gender/female/page/"+i.to_s)
    #end

    @gender="male"
    #for i in (1..105)
    #   sleep(1)
    #controller.read_page(controller, url+"gender/male/page/"+i.to_s)
    #end
   controller.read_individual_link(url)

    puts "Guests: "
    puts @castaways_table.length
    puts @guests.length

    #write to CSV:
    #

    output_results()
  end
end


collector = GetChoices.new
#collector.runner(collector, "http://www.bbc.co.uk/radio4/features/desert-island-discs/castaway/2343cdda")
#collector.runner(collector,"http://www.bbc.co.uk/radio4/features/desert-island-discs/find-a-castaway/")

# multiple books! 
collector.runner(collector, "http://www.bbc.co.uk/radio4/features/desert-island-discs/castaway/c4e2d05f#p009mhc8")
