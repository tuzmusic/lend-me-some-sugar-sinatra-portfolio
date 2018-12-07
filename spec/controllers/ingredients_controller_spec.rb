require 'spec_helper'
require 'pry'

describe ApplicationController do

 describe "new ingredient action" do
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

  describe "show ingredient action" do
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

  describe "edit ingredient action" do
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

      it "does not let a user edit a text with blank username" do
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

  describe "delete ingredient action" do
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
