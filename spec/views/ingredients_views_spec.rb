require 'spec_helper'
# require_relative './spec_helpers'

describe 'Ingredients Views' do

  describe "new page" do
    before do
      user = User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
      params = { username: "becky567", password: "kittens" }
      # post '/login', params

      visit '/'
      fill_in 'username', with: "becky567"
      fill_in 'password', with: "kittens"
      click_button 'Log In'
    end
    
    it "has a form to add up to ten ingredients" do
      visit '/ingredients/new'
      expect(page.status_code).to eq(200)
      expect(page.all('input[type=text]').count).to eq(10)
    end

    it "shows a user's current ingredients" do
      Ingredient.create(name:'parsley', user_id: User.last.id)
      Ingredient.create(name:'basil', user_id: User.last.id)
      Ingredient.create(name:'cumin', user_id: User.last.id)

      visit '/ingredients/new'
      expect(page.status_code).to eq(200)
      expect(page.body).to include('basil')
      expect(page.body).to include('parsley')
      expect(page.body).to include('cumin')
    end
  end

  describe "show page" do
    it "has a button to add ingredients" do
      expect(false).to eq(true)
    end

    it "has a button to edit ingredients" do
      expect(false).to eq(true)
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