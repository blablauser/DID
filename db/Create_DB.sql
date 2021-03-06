/* create DB: */
CREATE TABLE Castaway
(
castawayId INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT,
relatedLink TEXT, 
occupations TEXT,
gender TEXT,
PRIMARY KEY (castawayId)
)

CREATE TABLE Episode
(
episodeId INTEGER PRIMARY KEY AUTOINCREMENT,
castawayId INTEGER,
dateOfBroadcast TEXT,
occupationAtMomentOfBroadcast TEXT,
PRIMARY KEY (episodeId),
FOREIGN KEY (castawayId) REFERENCES Castaway(castawayId)
)


CREATE TABLE Song
(
songId INTEGER PRIMARY KEY AUTOINCREMENT,
trackTitle TEXT NOT NULL,
trackArtist TEXT NOT NULL,
trackComposer TEXT NOT NULL,
PRIMARY KEY (songId)
)
CREATE TABLE Book
(
bookId INTEGER PRIMARY KEY AUTOINCREMENT,
bookTitle TEXT NOT NULL,
bookAuthor TEXT NOT NULL,
PRIMARY KEY (bookId)
)
CREATE TABLE Luxury
(
luxuryId INTEGER PRIMARY KEY AUTOINCREMENT,
luxuryItem TEXT NOT NULL,
PRIMARY KEY (luxuryId)
)
CREATE TABLE SongChoice
(
songChoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
songId INTEGER,
episodeId INTEGER,
PRIMARY KEY (songChoiceId),
FOREIGN KEY (songId) REFERENCES Song(songId),
FOREIGN KEY (episodeId) REFERENCES Episode(episodeId)
)
CREATE TABLE BookChoice
(
bookChoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
bookId INTEGER,
episodeId INTEGER,
PRIMARY KEY (bookChoiceId),
FOREIGN KEY (bookId) REFERENCES Book(bookId),
FOREIGN KEY (episodeId) REFERENCES Episode(episodeId)
)
CREATE TABLE LuxuryChoice
(
luxuryChoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
luxuryId INTEGER,
episodeId INTEGER,
PRIMARY KEY (luxuryChoiceId),
FOREIGN KEY (luxuryId) REFERENCES Luxury(luxuryId),
FOREIGN KEY (episodeId) REFERENCES Episode(episodeId)
)
