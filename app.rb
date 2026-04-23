

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
      erb :'bands/create'
    end

    post '/bands' do
      db.execute('INSERT INTO bands (name, genre, started, best_song) VALUES (?,?,?,?)', params.values)
     redirect('/')
    end

    get '/login' do 
      erb :'users/login'
    end

    get '/show/:id' do | id |
      @bands = db.execute('SELECT * FROM bands WHERE id = ?', id).first
      p @bands
      @comments = db.execute('SELECT * FROM comments WHERE band_id = ?', id)
      erb :'bands/show'
    end

    post '/delete/:id' do | id |
      db.execute("DELETE FROM bands WHERE id =?", id)
      redirect('/')
    end

    get '/edit/:id' do | id |
      @bands = db.execute('SELECT * FROM bands WHERE id = ?', id).first
      erb :'bands/edit'
    end

    
    post '/update/:id' do | id |
      db.execute('UPDATE bands SET name=?, genre=?, started=?, best_song=? WHERE id=?', [params['name'], params['genre'], params['started'], params['best_song'], id])
      redirect('/')
    end


   get '/comment/:id' do |id|
  @bands = db.execute('SELECT * FROM bands WHERE id = ?', id).first
  erb :'comments/create'
end 

   post '/comment/:id' do |id|
  db.execute('INSERT INTO comments (comment, band_id) VALUES (?, ?)',[params['comment'], id])
  redirect("/show/#{id}")
end

    post '/delete/:id/comment' do | id |
      band_id = db.execute('SELECT band_id FROM comments WHERE id = ?', id).first['band_id']
      db.execute("DELETE FROM comments WHERE id = ?", id)
      redirect("/show/#{band_id}")
    end

    get '/edit/:id/comment' do |id|
  @comment = db.execute('SELECT * FROM comments WHERE id = ?', id).first
  erb :'comments/edit'
    end

    post '/update/:id/comment' do |id|
  band_id = db.execute('SELECT band_id FROM comments WHERE id = ?', id).first['band_id']

  db.execute(
    'UPDATE comments SET comment = ? WHERE id = ?',
    [params['comment'], id]
  )

  redirect("/show/#{band_id}")
end



# Inlog, users osv 

configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  before do
    if session[:user_id]
      @current_user = db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first
      ap @current_user
    end
  end


 get '/admin' do
    if session[:user_id]
      erb(:"admin/index")
    else
      ap "/admin : Access denied."
      status 401
      redirect '/acces_denied'
    end
  end

  get '/acces_denied' do
    erb(:acces_denied)
  end

  get '/login' do
    erb(:login)
  end

  post '/login' do
    request_username = params[:username]
    request_plain_password = params[:password]

    user = db.execute("SELECT *
            FROM users
            WHERE username = ?",
            request_username).first

    unless user
      ap "/login : Invalid username."
      status 401
      redirect '/acces_denied'
    end

    db_id = user["id"].to_i
    db_password_hashed = user["password"].to_s

    # Create a BCrypt object from the hashed password from db
    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    # Check if the plain password matches the hashed password from db
    if bcrypt_db_password == request_plain_password
      ap "/login : Logged in -> redirecting to admin"
      session[:user_id] = db_id
      redirect '/admin'
    else
      ap "/login : Invalid password."
      status 401
      redirect '/acces_denied'
    end
  end

  post '/logout' do
    ap "Logging out"
    session.clear
    redirect '/'
  end

  get '/users/new' do
    erb(:"users/new")
  end

end

