require 'spec_helper'
require 'pry'

describe ApplicationController do

  describe "Layout" do
    it "includes a header" do
      get '/index'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Lend Me Some Sugar")
      expect(last_response.body).to include("Users")
      expect(last_response.body).to include("Browse Ingredients")
      expect(last_response.body).to include("Search Ingredients")
    end
  end

  describe "Homepage/Login Page" do
    it "loads the homepage" do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome!")
    end
    
    it "includes a link to sign up" do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Sign Up")
    end
    
    it "lets you log in directly from the homepage" do
      get '/'
      expect(page).to have_field(:name)
      expect(page).to have_field(:password)
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
      params = { :name => "becky567", :password => "kittens" }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Login failed: User 'becky567' not found.")
    end

    it "displays a failure message if the password is incorrect" do
      UserHelper.create_user
      params = { :name => "becky567", :password => "kittensssss" }
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

  describe "new action" do
    context 'logged in' do
      it "lets user view new ingredient form if logged in" do
        UserHelper.create_and_login_user
        visit '/ingredients/new'
        expect(page.status_code).to eq(200)
      end

      it "lets user create up to 10 ingredients if they are logged in" do
        UserHelper.create_and_login_user

        visit '/ingredients/new'
        expect(false).to eq(true)
        # fill_in(:name, :with => "tweet!!!")
        # click_button 'submit'

        # user = User.find_by(:name => "becky567")
        # ingredient = Ingredient.find_by(:name => "tweet!!!")
        # expect(ingredient).to be_instance_of(Ingredient)
        # expect(ingredient.user_id).to eq(user.id)
        # expect(page.status_code).to eq(200)
      end

      it "does not let a user save zero ingredients" do 
        expect(false).to eq(true) 
      end

      it "lets a user leave some ingredients blank (as long as they're not all blank)" do
        expect(false).to eq(true)
      end
    end

    context 'logged out' do
      it "does not let user view new ingredients form if not logged in" do
        get '/ingredients/new'
        expect(last_response.location).to include("/")
      end
    end
  end

  describe "show action" do
    context 'logged in' do
      it "displays an ingredient and shows all users who have listed that ingredient (by text search, not by 'ingredient has_many :users')" do
        expect(false).to eq(true)
      end
    end

    context 'logged out' do
      it "does not let a user view an ingredient" do
        user = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        ingredient = UserHelper.create_parsley
        get "/ingredients/#{ingredient.id}"
        expect(last_response.location).to include("/")
      end
    end
  end

  describe "edit action" do
    context "logged in" do
      it "lets a user view tweet edit form if they are logged in" do
        user = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Ingredient.create(:name => "tweeting!", :user_id => user.id)
        visit '/login'

        fill_in(:name, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/ingredients/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(tweet:name
      end

      it "does not let a user edit a tweet they did not create" do
        user1 = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Ingredient.create(:name => "tweeting!", :user_id => user1.id)

        user2 = User.create(:name => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Ingredient.create(:name => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:name, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/ingredients/#{tweet2.id}/edit"
        expect(page.current_path).to include('/index')
      end

      it "lets a user edit their own tweet if they are logged in" do
        user = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Ingredient.create(:name => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:name, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/ingredients/1/edit'

        fill_in(:name, :with => "i love tweeting")

        click_button 'submit'
        expect(Ingredient.find_by(:name => "i love tweeting")).to be_instance_of(Ingredient)
        expect(Ingredient.find_by(:name => "tweeting!")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it "does not let a user edit a text with blank:name do
        user = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Ingredient.create(:name => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:name, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/ingredients/1/edit'

        fill_in(:name, :with => "")

        click_button 'submit'
        expect(Ingredient.find_by(:name => "i love tweeting")).to be(nil)
        expect(page.current_path).to eq("/ingredients/1/edit")
      end
    end

    context "logged out" do
      it "does not load -- instead redirects to login" do
        get '/ingredients/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe "delete action" do
    context "logged in" do
      it "lets a user delete their own tweet if they are logged in" do
        user = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Ingredient.create(:name => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:name, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'tweets/1'
        click_button "Delete Ingredient"
        expect(page.status_code).to eq(200)
        expect(Ingredient.find_by(:name => "tweeting!")).to eq(nil)
      end

      it "does not let a user delete a tweet they did not create" do
        user1 = User.create(:name => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Ingredient.create(:name => "tweeting!", :user_id => user1.id)

        user2 = User.create(:name => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Ingredient.create(:name => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:name, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "tweets/#{tweet2.id}"
        click_button "Delete Ingredient"
        expect(page.status_code).to eq(200)
        expect(Ingredient.find_by(:name => "look at this tweet")).to be_instance_of(Ingredient)
        expect(page.current_path).to include('/index')
      end
    end

    context "logged out" do
      it "does not load let user delete a tweet if not logged in" do
        tweet = Ingredient.create(:name => "tweeting!", :user_id => 1)
        visit '/ingredients/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
