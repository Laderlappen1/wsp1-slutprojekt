require 'sqlite3'

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
                name TEXT NOT NULL,
                password TEXT NOT NULL,
                user_id INTEGER)')

    db.execute('CREATE TABLE comments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                comment_id)')
  end

  def self.populate_tables 
    db.execute('INSERT INTO bands (name, genre, started, best_song) VALUES ("Metallica", "Thrash Metal", 1981, "Master of Puppets")')
    db.execute('INSERT INTO bands (name, genre, started, best_song) VALUES ("Gojira", "Metal", 1996, "Sphinx")')
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/sqlite.db')
    @db.results_as_hash = true
    @db
  end
end

