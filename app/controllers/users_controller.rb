class UserController < ApplicationController

  # Welcome Action
  get '/' do
    if session[:id]
      redirect '/index'
    else
      erb :welcome
    end
  end

  # Login Action
  post '/login' do
    if params[:username].empty? || params[:password].empty? 
      session[:flash] = "You must enter a username and password."
      redirect '/' 
    else 
      user = User.find_by(username: params[:username])    
      if user && user.authenticate(params[:password])
        session[:id] = user.id
        redirect '/index'
      else
        session[:flash] = "Login failed: " + (user ? "Incorrect password." : "User '#{params[:username]}' not found.")
        redirect '/'
      end
    end
  end

  # Logout Action
  get '/logout' do
    session.delete(:id)
    redirect '/'
  end

  # New User Action
  get '/signup' do
    if session[:id]
      redirect '/index'
    else
      erb :signup
    end
  end
  
  # Create User (Sign Up) Action
  post '/users' do
    valid_email_regex = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    username, email, password = params[:user][:username], params[:user][:password], params[:user][:email]
    if params[:user][:username].empty? || params[:user][:password].empty? || params[:user][:email].empty?
      session[:flash] = "You must enter a username, email and password."
      redirect '/signup' 
    elsif User.find_by(username: params[:user][:username])
      session[:flash] = "Username '#{params[:user][:username]}' already exists. Try another username."
      redirect '/signup' 
    elsif !(params[:user][:email] =~ valid_email_regex)
      session[:flash] = "You must enter a valid email address."
      redirect '/signup' 
    else 
      user = User.create(params['user'])
      user.save
      session[:id] = user.id
      redirect "/index"
    end
  end
  
  # Index Action
  get '/index' do
    if session[:id]
      @users = User.all
      @current_user = current_user
      @ingredients = Ingredient.all
      erb :index
    else
      redirect '/'
    end
  end
  
  # Show User Action
  get '/users/:slug' do
    if session[:id]
      @user = User.find_by_slug(params[:slug])
      @current_user = current_user
      erb :'/users/show'
    else
      redirect '/'
    end
  end
  
  # Edit Action
  get '/users/:id/edit' do
    @user = User.find(params[:id])
    @ingredients = Ingredient.all
    erb :'/users/edit'
  end
  
  # Patch Action
  patch '/users/:id' do
    params[:song_info]['ingredient_ids'].clear if !params[:user].keys.include?('ingredient_ids')
    user = User.find(params[:id])
    user.update(params['user'])

    user.ingredients << Ingredient.create(name: params['ingredient_name']) unless params['ingredient_name'].empty?
    user.save
    redirect "users/#{user.id}"
  end
  
  # Delete Action
  delete '/users/:id' do
    user = User.find(params[:id])
    user.delete
  end
  
end