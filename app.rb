require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:index)
end

get('/newuser') do 
    slim(:register)

end

post('/login') do
    # om id:t för användarnamn och password är samma, redirect till startsidan
    # om det inte är samma redirect till access denied
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    usercred = db.execute("SELECT username, password FROM users WHERE username =?",params["username"])
    if usercred == []
        redirect('/denied')
    end

    if checkpassword(usercred[0][1],params["password"]) == true 
        redirect("/welcome")
    else
        redirect("/denied")
    end

    

end
get('/denied') do
    slim(:denied)
end

post('/register') do
    db = SQLite3::Database.new("db/database.db") 
    hashedpassword = BCrypt::Password.create(params["password"])
    begin
        db.execute("INSERT INTO users(username,password) VALUES (?,?)",params["username"],hashedpassword)
    rescue SQLite3::ConstraintException => exception
        session[:usernameerror] = true
        redirect('/newuser')
    end

end


def checkpassword(dbps,ps)
    if dbps == BCrypt::Password.create(ps)
        sessions[:username] = usercred[0][0]
        return true
    else
        return false
    end
end
