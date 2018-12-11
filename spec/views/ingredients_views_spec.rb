require 'spec_helper'
# require_relative './spec_helpers'

describe 'Ingredients Views' do

  describe "index page" do
    
  end

  describe "show page" do
    it "displays an ingredient and shows all users who have listed that ingredient (by text search, not by 'ingredient has_many :users')" do
      expect(false).to eq(true)
    end
    
    it "links to each user's show page" do
      expect(false).to eq(true)
    end
    
  end
  
  describe "new page" do
    before do
      user = User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      params = { username: "becky567", password: "kittens" }
      post '/login', params
    end
    
    it "has a form to add up to ten ingredients" do
      visit '/ingredients/new'
      expect(page.status_code).to eq(200)
      expect(page.all('input[type=text]').count).to eq(10)
    end

    it "shows a user's current ingredients" do
      Ingredient.create(name:'parsley')
      Ingredient.create(name:'basil')
      Ingredient.create(name:'cumin')

      visit '/ingredients/new'
      expect(page.status_code).to eq(200)
      expect(page).to have_content('basil')
      expect(page).to have_content('parsley')
      expect(page).to have_content('cumin')
    end
  end

  describe "edit page" do
    it "shows all the user's ingredients" do
      expect(false).to eq(true)
    end

    it "has a delete button for each ingredient" do
      expect(false).to eq(true)
    end

    it "has a 'save all' button" do
      
    end
  end

end