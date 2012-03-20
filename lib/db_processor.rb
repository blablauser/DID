require 'sqlite3'
require 'csv'
class DbProcessor
  def self.create_db
    File.delete("did1.db")
    @db = SQLite3::Database.new("did1.db")
    @db.execute("CREATE TABLE Castaway
(castawayId INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT,
relatedLink TEXT, 
occupations TEXT,
gender TEXT
)")
    @db.execute("CREATE TABLE Episode
(episodeId INTEGER PRIMARY KEY AUTOINCREMENT,
castawayId INTEGER,
dateOfBroadcast TEXT,
occupationAtMomentOfBroadcast TEXT,
FOREIGN KEY (castawayId) REFERENCES Castaway(castawayId)
)")
    @db.execute("CREATE TABLE Song
(songId INTEGER PRIMARY KEY AUTOINCREMENT,
trackTitle TEXT NOT NULL,
trackArtist TEXT NOT NULL,
trackComposer TEXT NOT NULL
)")
    @db.execute("CREATE TABLE Book
(
bookId INTEGER PRIMARY KEY AUTOINCREMENT,
bookTitle TEXT NOT NULL,
bookAuthor TEXT NOT NULL
)")
    @db.execute("CREATE TABLE Luxury
(
luxuryId INTEGER PRIMARY KEY AUTOINCREMENT,
luxuryItem TEXT NOT NULL
)")
    @db.execute("CREATE TABLE SongChoice
(
songChoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
songId INTEGER,
episodeId INTEGER,
FOREIGN KEY (songId) REFERENCES Song(songId),
FOREIGN KEY (episodeId) REFERENCES Episode(episodeId)
)")
    @db.execute("CREATE TABLE BookChoice
(
bookChoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
bookId INTEGER,
episodeId INTEGER,
FOREIGN KEY (bookId) REFERENCES Book(bookId),
FOREIGN KEY (episodeId) REFERENCES Episode(episodeId)
)")
    @db.execute("CREATE TABLE LuxuryChoice
(
luxuryChoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
luxuryId INTEGER,
episodeId INTEGER,
FOREIGN KEY (luxuryId) REFERENCES Luxury(luxuryId),
FOREIGN KEY (episodeId) REFERENCES Episode(episodeId)
)")
    puts @db.execute("select count(*) from Episode")
  end

  def self.test_query
    @db = SQLite3::Database.new("did1.db")
    puts "put query:"
    while ((query=gets.chomp)!="Exit")
      puts @db.execute query
      puts "put query:"
    end
  end
end
DbProcessor.create_db

DbProcessor.test_query
