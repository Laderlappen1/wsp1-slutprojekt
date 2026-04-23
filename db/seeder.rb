  require 'sqlite3'
  require_relative '../config'
  require 'bcrypt'

  class Seeder

    def self.seed!
      drop_tables
      create_tables
      populate_tables
    end

    def self.drop_tables
      db.execute('DROP TABLE IF EXISTS bands')
      db.execute('DROP TABLE IF EXISTS users')
      db.execute('DROP TABLE IF EXISTS comments')
    end

    def self.create_tables
      db.execute('CREATE TABLE bands (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL,
                  genre TEXT,
                  started INTEGER,
                  best_song TEXT)')

      db.execute('CREATE TABLE users (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  username TEXT NOT NULL,
                  password TEXT NOT NULL,
                  user_id INTEGER)')

      db.execute('CREATE TABLE comments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  comment TEXT NOT NULL,
                  band_id INTEGER)')
    end

    def self.populate_tables 
      db.execute('INSERT INTO bands (name, genre, started, best_song) VALUES ("Metallica", "Thrash Metal", 1981, "Master of Puppets")')
      db.execute('INSERT INTO bands (name, genre, started, best_song) VALUES ("Gojira", "Metal", 1996, "Sphinx")')
      
      db.execute('INSERT INTO comments (band_id, comment) VALUES (1, "The first metal band I ever heard, my mother used to turn on Metallica in the car and we would listen to The Black Album. A small step for metal, a big step for me!")')
      db.execute('INSERT INTO comments (band_id, comment) VALUES (1, "Master of Puppets was my favorite and my most played song for about three years. Does not make the cut like the songs I listen to today. But it is still amazing.")')
      db.execute('INSERT INTO comments (band_id, comment) VALUES (2, "A newer band that I started to listen to last year. Amazing songs and heavy af. Love that they were the first band to ever play at the Olympics. Continue the great work and let some whales fly from the sky!")')


      password_hashed = BCrypt::Password.create("123")
          db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Kowalski", password_hashed])

      
    end

    private
    def self.db
      return @db if @db
      @db = SQLite3::Database.new('db/sqlite.db')
      @db.results_as_hash = true
      @db
    end
  end

