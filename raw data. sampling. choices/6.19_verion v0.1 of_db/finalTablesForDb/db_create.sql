
CREATE TABLE castaway (castawayID INT(11) NOT NULL,
		       name text NOT NULL,
                       link text NOT NULL, 
                       genre text NOT NULL,
                       occupation text NOT NULL,
                       PRIMARY KEY (castawayID)) ENGINE=INNODB;

CREATE TABLE luxury (luxuryID INT(11) NOT NULL,
		       luxuryItem text NOT NULL,
                       
                       PRIMARY KEY (luxuryID)) ENGINE=INNODB;


CREATE TABLE episode (
  episodeID int(11) NOT NULL,
  castawayID int(11) NOT NULL,
  luxuryID int(11) NOT NULL,
  dateOfBroadcast varchar(15) collate utf8_unicode_ci NOT NULL,
  occupations text collate utf8_unicode_ci NOT NULL,
  PRIMARY KEY  (episodeID),
  KEY castawayID (castawayID),
  INDEX  (luxuryID),
			      FOREIGN KEY (luxuryID)
                              REFERENCES luxury(luxuryID)
                              ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


CREATE TABLE book (
  bookID int(11) NOT NULL,
  author text collate utf8_unicode_ci NOT NULL,
  title text collate utf8_unicode_ci NOT NULL,
  KEY bookID (bookID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS record (
  recordID int(11) NOT NULL,
  artist text collate utf8_unicode_ci NOT NULL,
  title text collate utf8_unicode_ci NOT NULL,
  composer text collate utf8_unicode_ci NOT NULL,
  PRIMARY KEY  (recordID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS bookChoice (
			      bookChoiceID int(11) NOT NULL auto_increment,
			      episodeID int(11) NOT NULL,
			      bookID int(11) NOT NULL,
			      PRIMARY KEY  (episodeID, bookID),
			      KEY  (bookChoiceID),
			      INDEX  (episodeID),
			      FOREIGN KEY (episodeID)
                              REFERENCES episode(episodeID)
                              ON UPDATE CASCADE ON DELETE CASCADE,
			      INDEX  (bookID),
			      FOREIGN KEY (bookID)
                              REFERENCES book(bookID)
                              ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1; 


CREATE TABLE IF NOT EXISTS recordChoice (
  recordChoiceID int(11) NOT NULL auto_increment,
  episodeID int(11) NOT NULL,
  recordID int(11) NOT NULL,
  choiceNr int(1) NOT NULL,
  favourite tinyint(1) NOT NULL,
  PRIMARY KEY  (episodeID,recordID),
  KEY (recordChoiceID),
  INDEX  (episodeID),
			      FOREIGN KEY (episodeID)
                              REFERENCES episode(episodeID)
                              ON UPDATE CASCADE ON DELETE CASCADE,
 INDEX  (recordID),
			      FOREIGN KEY (recordID)
                              REFERENCES record(recordID)
                              ON UPDATE CASCADE ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
