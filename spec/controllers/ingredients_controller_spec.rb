require 'spec_helper'
require_relative './spec_helpers'
require 'pry'

describe 'Ingredients Controller' do

  describe "new ingredient action" do    
    context "logged out" do
      it "does not let user view new ingredients form if not logged in" do
        get '/ingredients/new'
        expect(last_response.body).to include("Welcome")
      end
    end

    context "logged in" do
      before do
        User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
        params = { username: "becky567", password: "kittens" }
        post '/login', params           
      end
      
      it "lets user view new ingredient form if logged in" do
        visit '/ingredients/new'
        expect(page.status_code).to eq(200)
        expect(page).to have_content 'Add Ingredients'
      end
      
      it "lets user create up to 10 ingredients if they are logged in" do      
        visit '/ingredients/new'
        expect(page.status_code).to eq(200)
        expect(page.all('input[type=text]').count).to eq(10)
      end

      it "does not let a user save zero ingredients" do 
        expect(false).to eq(true) 
      end
    end
  end
  
  describe "show ingredient action" do
    it "lets the user access the ingredient show page if logged in" do
      user = UserHelper.create_user
      ingredient = UserHelper.create_parsley(user)
      get "/ingredients/#{ingredient.id}"
      expect(last_response.body).to include(ingredient.name)
    end

    it "does not let a user view an ingredient show page if logged out" do
      user = UserHelper.create_user
      ingredient = UserHelper.create_parsley(user)
      get "/ingredients/#{ingredient.id}"
      expect(last_response.location).to include("/")
    end
  end

  describe "edit ingredient action" do
    it "lets a user view ingredient edit form if they are logged in" do
      user = UserHelper.create_and_login_user
      ingredient = UserHelper.create_parsley(user)
      visit '/ingredients/1/edit'
      expect(page.status_code).to eq(200)
      expect(page.body).to include("Edit Your Ingredients")
    end

    it "lets a user edit their ingedients (if they are logged in)" do
      user = UserHelper.create_user_and_click_login
      ingredient = UserHelper.create_parsley(user)
      visit '/ingredients/edit'

      # fill_in(:name, with: "i love tweeting")

      # click_button 'submit'
      # expect(Ingredient.find_by(name: "i love tweeting")).to be_instance_of(Ingredient)
      # expect(Ingredient.find_by(name: "tweeting!")).to eq(nil)
      # expect(page.status_code).to eq(200)
    end

    it "does not let a user edit an ingredient with blank username" do
      user = UserHelper.create_user_and_click_login
      ingredient = UserHelper.create_parsley(user)
      # visit '/ingredients/1/edit'

      # fill_in(:name, with: "")

      # click_button 'submit'
      # expect(Ingredient.find_by(name: "i love tweeting")).to be(nil)
      # expect(page.current_path).to eq("/ingredients/1/edit")
    end

    it "lets a user delete an ingredient" do
      
    end

    it "does not load edit page if not logged in -- instead redirects to home page" do
      get '/ingredients/1/edit'
      expect(last_response.location).to include("/")
    end
  end

  describe "delete ingredient action" do
    context "logged in" do
      it "lets a user delete their own ingredient if they are logged in" do
        user = UserHelper.create_user_and_click_login
        ingredient = UserHelper.create_parsley(user)
        visit 'tweets/1'
        click_button "Delete Ingredient"
        expect(page.status_code).to eq(200)
        expect(Ingredient.find_by(name: "tweeting!")).to eq(nil)
      end

      it "does not let a user delete an ingredient they did not create" do

        expect('the show page is different from the model in twitter...').to eq()
        user = UserHelper.create_user_and_click_login
        ingredient = UserHelper.create_parsley(user)

        user2 = User.create(name: "silverstallion", email: "silver@aol.com", password: "horses")
        tweet2 = Ingredient.create(name: "paprika", user_id: user2.id)

        visit "ingredients/#{ingredient2.id}"
        click_button "Delete Ingredient"
        expect(page.status_code).to eq(200)
        expect(Ingredient.find_by(name: "paprika")).to be_instance_of(Ingredient)
        expect(page.current_path).to include('/index')
      end
    end

    context "logged out" do
      it "does not load let user delete an ingredient if not logged in" do
        expect(false).to eq(true)
        tweet = Ingredient.create(name: "sugar", user_id: 1)
        visit '/ingredients/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
