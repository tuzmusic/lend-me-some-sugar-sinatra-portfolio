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

    it "can log in an existing user" do
      user = UserHelper.create_and_login_user
      expect(session[:id]).to eq(user.id)
    end

    it "loads the index page after login" do
      UserHelper.create_and_login_user
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.location).to include('/index')
    end

    it "redirects you to the index if already logged in" do
      UserHelper.create_and_login_user
      get '/'
      expect(last_response.location).to include('/index')      
    end

    it "displays a failure message if no user is found" do
      params = { :username => "becky567", :password => "kittens" }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Login failed: User 'becky567' not found.")
    end

    it "displays a failure message if the password is incorrect" do
      UserHelper.create_user
      params = { :username => "becky567", :password => "kittensssss" }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Login failed: Incorrect password.")
    end
  end

  describe "Signup Page" do

    it "loads the signup page" do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it "directs user to the index page once they've signed up"  do
      UserHelper.sign_up_user  
      expect(last_response.location).to include("/index")
    end

    it "does not let a user sign up without a username" do
      UserHelper.sign_up_user  
      expect(last_response.location).to include('/signup')
      expect(last_response.body).to include('You must enter a username.')
    end

    it "does not let a user sign up without an email" do
      UserHelper.sign_up_user  
      expect(last_response.location).to include('/signup')
      expect(last_response.body).to include('You must enter an email address.')
    end

    it "does not let a user sign up without a password" do
      UserHelper.sign_up_user  
      expect(last_response.location).to include('/signup')
      expect(last_response.body).to include('You must enter a password.')
    end

    it "redirects a logged in user to the index page" do
      UserHelper.sign_up_user  
      post '/signup', params
      get '/signup'
      expect(last_response.location).to include('/index')
    end
  end

  describe "logout" do
    it "lets a user logout, and directs them to the index page, if they are already logged in" do
      UserHelper.create_and_login_user
      get '/logout'
      expect(last_response.location).to include("/index")
    end

    it "does not let a user logout if not logged in" do
      get '/logout'
      expect(last_response.location).to include("/")
    end

    it "does not load /index if user not logged in" do
      get '/index'
      expect(last_response.location).to include("/")
    end
  end

  describe "user show page" do
    it "shows all a single user's ingredients" do
      user = UserHelper.create_user
      ingredient1 = Ingredient.create(:name => "parsley", :user_id => user.id)
      ingredient2 = Ingredient.create(:name => "cumin", :user_id => user.id)
      get "/users/#{user.slug}"
      expect(page.current_path).to eq('/index')  # this is the right way to test, right?
      expect(page.body).to include("parsley")
      expect(page.body).to include("cumin")
    end
  end

  describe "index action" do
    context 'logged in' do
      it "lets a user view the index page if logged in" do
        UserHelper.create_user_and_click_login
        visit "/index"
        expect(last_response.status).to eq(200)
        expect(last_response.location).to include("/index")
      end
    end

    context 'logged out' do
      it "does not let a user view the index if not logged in" do
        get '/index'
        expect(last_response.location).to include("/")
      end
    end
  end

end
