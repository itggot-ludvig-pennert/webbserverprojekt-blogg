require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

db = SQLite3::Database.new("db/database.db")
db.results_as_hash = true

post('/newpost') do
    user = session[:username]
    content = params["content"]
    db.execute("INSERT INTO posts (content, username) VALUES ('#{content}', '#{user}')")
    redirect('/welcome')
end

get('/') do
    slim(:index)
end

get('/newuser') do 
    slim(:register)

end

get('/welcome') do
    if session[:username] == nil
        redirect('/denied') 
    end
    slim(:welcome)
end

get('/welcome/:profile') do
    session[:profile] = params[:profile]
    slim(:profile)
end

post('/deletepost') do
    db.execute("DELETE FROM posts WHERE postid = #{params[:postid]}")
    redirect('/welcome')
end

post('/login') do
    # om id:t för användarnamn och password är samma, redirect till startsidan
    # om det inte är samma redirect till access denied
    usercred = db.execute("SELECT username, password FROM users WHERE username =?",params["username"])
    if usercred == []
        redirect('/denied')
    end
    if checkpassword(usercred[0][1],params["password"],usercred[0][0]) == true 
        redirect("/welcome")
    else
        redirect("/denied")
    end
end

get('/denied') do
    slim(:denied)
end

post('/register') do
    begin
        db.execute("INSERT INTO users(username,password) VALUES (?,?)",params["username"],hashedpassword)
    rescue SQLite3::ConstraintException => exception
        session[:usernameerror] = true
        redirect('/newuser')
    end
    session[:username] = params["username"]
    redirect('/welcome')
end

get('/logout') do 
    session[:username] = nil
    redirect('/')
end


def checkpassword(dbps,ps,un)
    if BCrypt::Password.new(dbps) == ps
        session[:username] = un
        return true
    else
        return false
    end
end
