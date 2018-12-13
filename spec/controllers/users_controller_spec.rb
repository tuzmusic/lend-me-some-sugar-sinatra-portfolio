require 'spec_helper'
require 'pry'
require_relative './spec_helpers'

describe 'Users & Main Controller' do

  describe "Homepage/Login Page" do
    it "loads the homepage at '/'" do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome!")
    end

    it "loads the index page after login" do
      User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      params = { username: "becky567", password: "kittens" }
      post '/login', params 
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Lend Me Some Sugar')
    end

    it "redirects you to the index if already logged in" do
      User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      params = { username: "becky567", password: "kittens" }
      post '/login', params   
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Lend Me Some Sugar')
    end

    it "displays a failure message if no user is found" do
      params = { username: "becky567", password: "kittens" }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Login failed: User 'becky567' not found.")
    end

    it "displays a failure message if the password is incorrect" do
      UserHelper.create_user
      params = { username: "becky567", password: "kittensssss" }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Login failed: Incorrect password.")
    end
    
    it "displays a failure message if no username is entered" do
      params = { username: "", password: "1345ty" }
      post '/login', params     
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("You must enter a username and password.")
    end
    
    it "displays a failure message if no password is entered" do
      params = { username: "becky567", password: "" }
      post '/login', params     
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("You must enter a username and password.")
    end
  end

  describe "Signup Page" do

    it "loads the signup page" do
      get '/signup'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Sign Up')
    end

    it "directs user to the index page once they've signed up"  do
      params = {  'user[username]': "skittles123", 'user[email]': "skittles@aol.com", 'user[password]': "rainbows" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Lend Me Some Sugar')
    end

    it "does not let a user sign up without a username" do
      params = { 'user[username]': "", 'user[email]': "skittles@aol.com", 'user[password]': "rainbows" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('You must enter a username, email and password.')
    end

    it "does not let a user sign up without an email" do
      params = { 'user[username]': "skittles123", 'user[email]': "", 'user[password]': "rainbows" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('You must enter a username, email and password.')
    end

    it "does not let a user sign up without a password" do
      params = { 'user[username]': "skittles123", 'user[email]': "skittles@aol.com", 'user[password]': "1234" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('You must enter a username, email and password.')
    end

    it "does not let a user sign up with an invalid email address" do
      params = { 'user[username]': "skittles123", 'user[email]': "skittlesaol.com", 'user[password]': "1234" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('You must enter a valid email address.')
    end
    
    it "does not let a user sign up with an existing username" do
      User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      params = { 'user[username]': "becky567", 'user[email]': "skittlesaol.com", 'user[password]': "" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Username 'becky567' already exists. Try another username.")
    end

    it "redirects a logged in user to the index page" do
      params = {  'user[username]': "skittles123", 'user[email]': "skittles@aol.com", 'user[password]': "rainbows" }
      post '/users', params  
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Lend Me Some Sugar')
    end
  end

  describe "logout" do
    it "lets a user logout, and directs them to the index page, if they are already logged in" do
      User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      params = { username: "becky567", password: "kittens" }
      post '/login', params   
      get '/logout'
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Welcome')
    end
  end

  describe "user show page" do
    it "does not show the show page if not logged in" do
      user = User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      get "/users/#{user.slug}"
      expect(last_response.status).to eq(302)
      follow_redirect!      
      expect(last_response.body).to include('Welcome!')
    end
  
    context "logged in" do
      before do
        User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
        params = { username: "becky567", password: "kittens" }
        post '/login', params           
      end
      
      it "navigates to the show page if logged in" do
        get "/users/becky567"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("becky567")
      end

      it "shows all a single user's ingredients" do
        user = User.last
        ingredient1 = Ingredient.create(name: "parsley", user_id: user.id)
        ingredient2 = Ingredient.create(name: "cumin", user_id: user.id)
        get "/users/becky567"
        expect(last_response.body).to include("parsley")
        expect(last_response.body).to include("cumin")
      end
    end
  end

  describe "index action" do
    context 'logged out' do
      it "does not let a user view the index if not logged in" do
        get '/index'
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_response.status).to eq(200)        
        expect(last_response.body).to include("Welcome")
      end
    end
    
    context 'logged in' do
      before do
        User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
        params = { username: "becky567", password: "kittens" }
        post '/login', params           
      end
      
      it "lets a user view the index page if logged in" do
        get "/index"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Lend Me Some Sugar!")
      end
      
      it "lists all the users" do
        User.create(username: "becky568", email: "starz@aol.com", password: "kittens")
        User.create(username: "becky569", email: "starz@aol.com", password: "kittens")

        get "/index"
        expect(last_response.body).to include("becky567")
        expect(last_response.body).to include("becky568")
        expect(last_response.body).to include("becky569")
      end

      it "links to each user's show page" do
        get '/index'
        expect(last_response.body).to include("/users/becky567")
      end
    end
  end

end
