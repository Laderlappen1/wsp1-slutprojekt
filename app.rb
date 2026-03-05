require 'debug'
require "awesome_print"

class App < Sinatra::Base

    setup_development_features(self)

    # Funktion för att prata med databasen
    # Exempel på användning: db.execute('SELECT * FROM fruits')
    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    # Routen /
    get '/' do

      @bands = db.execute('SELECT * FROM bands')
      erb :index
    end

    get '/skapa' do 
      erb :create
    end

    post '/create' do
      db.execute('INSERT INTO bands (name, genre, started, best_song) VALUES (?,?,?,?)', params.values)
     redirect('/')
    end

    get '/login' do 
      erb :login
    end

    get '/show/:id' do | id |
      @bands = db.execute('SELECT * FROM bands WHERE id = ?', id).first
      p @bands
      erb :show
    end

    post '/delete/:id' do | id |
      db.execute("DELETE FROM bands WHERE id =?", id)
      redirect('/')
    end

    #get '/update' do 
     # erb
end

