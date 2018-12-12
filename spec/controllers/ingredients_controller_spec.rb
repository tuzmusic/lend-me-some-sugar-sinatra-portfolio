require 'spec_helper'
require_relative './spec_helpers'
require 'pry'

describe 'Ingredients Controller' do

  describe "new ingredient action" do    
    context "logged out" do
      it "does not let user view new ingredients form if not logged in" do
        get '/ingredients/new'
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_response.status).to eq(200)
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
        get '/ingredients/new'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include 'Add Ingredients'
      end
      
      it "lets user create up to 10 ingredients" do      
        ingredients = ['1st','2nd','3rd','4th','5th','6th','7th','8th','9th','10th']
        params = {ingredients:[]}
        ingredients.each { |i| params[:ingredients] << { name: i } }
        expect(ingredients.count).to eq 10
      
        expect{post '/ingredients', params}.to change{Ingredient.all.count}.by(10)
      end

      it "assigns the ingredients to the current user" do
        ingredients = ['1st','2nd','3rd','4th','5th','6th','7th','8th','9th','10th']
        params = {ingredients:[]}
        ingredients.each { |i| params[:ingredients] << { name: i } }
      
        expect{post '/ingredients', params}.to change{User.last.ingredients.count}.by(10)
      end

      it "doesn't assign the ingredients to a different user" do
        ingredients = ['1st','2nd','3rd','4th','5th','6th','7th','8th','9th','10th']
        params = {ingredients:[]}
        ingredients.each { |i| params[:ingredients] << { name: i } }
        User.create(username: "another_user", email: "starz@aol.com", password: "kittens")
        
        expect{post '/ingredients', params}.to change{User.last.ingredients.count}.by(0)
      end

      it "lets user create less than 10 ingredients" do      
        ingredients = ['1st','2nd','3rd','4th','','','','','','']
        params = {ingredients:[]}
        ingredients.each { |i| params[:ingredients] << { name: i } }
      
        expect{post '/ingredients', params}.to change{Ingredient.all.count}.by(4)
      end
      
      it "redirects to the user's show page" do
        ingredients = ['1st','2nd','3rd','4th','','','','','','']
        params = {ingredients:[]}
        ingredients.each { |i| params[:ingredients] << { name: i } }
      
        post '/ingredients', params
        
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("becky567's ingredients")
      end
    end
  end
  
  describe "edit ingredients action" do
    context "logged out" do
      it "doesn't let a user view ingredient edit form if they are logged out" do
        get '/ingredients/edit'
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Welcome")
      end
    end
    
     context "logged in" do
      before do
        user = User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
        Ingredient.create(name: 'parsley', user_id: user.id)
        Ingredient.create(name: 'cumin', user_id: user.id)
        Ingredient.create(name: 'basil', user_id: user.id)
                
        visit '/'
        fill_in('username', with: 'becky567')
        fill_in('password', with: 'kittens')
        click_button 'Log In'
        visit '/ingredients/edit'
      end
      
      it "lets a user view ingredient edit form if they are logged in" do
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Edit Your Ingredients")
      end

      it "doesn't show another user's ingredients" do
        user2 = User.create(username: "another", email: "starz@aol.com", password: "kittens")
        Ingredient.create(name: 'celery', user_id: user2.id)
        
        visit '/ingredients/edit'
        expect(page.body).not_to include('celery')
      end

      it "show's a user's ingredients" do
        expect(page.status_code).to eq(200)
        expect(page.all('input[type=text]').count).to eq(3)        
        expect(page.body).to include('parsley')
        expect(page.body).to include('cumin')
        expect(page.body).to include('basil')
      end
  
      it "lets a user edit a single ingedient" do
        fill_in("#{Ingredient.first.id}-field", with: "paprika")  
        click_button 'Save'

        expect(Ingredient.find_by(name: "paprika")).to be_instance_of(Ingredient)
        expect(Ingredient.find_by(name: "parsley")).to eq(nil)
        expect(User.first.ingredients.first.name).to eq('paprika')
        expect(User.first.ingredients.last.name).to eq('basil')
        expect(page.status_code).to eq(200)
      end
      
      it "lets a user edit multiple ingedients" do
        fill_in("#{Ingredient.first.id}-field", with: "paprika")  
        fill_in("#{Ingredient.last.id}-field", with: "lettuce")  
        click_button 'Save'

        expect(Ingredient.find_by(name: "paprika")).to be_instance_of(Ingredient)
        expect(Ingredient.find_by(name: "lettuce")).to be_instance_of(Ingredient)
        expect(Ingredient.find_by(name: "parsley")).to eq(nil)
        expect(Ingredient.find_by(name: "basil")).to eq(nil)
        expect(User.first.ingredients.first.name).to eq('paprika')
        expect(User.first.ingredients.last.name).to eq('lettuce')
        expect(page.status_code).to eq(200)
      end
      
      it "redirects to the user's show page" do
        click_button 'Save'
        expect(page.body).to include("becky567's ingredients")
      end

      it "has checkboxes for deleting each ingredient" do
        expect(page.all('input[type=checkbox]').count).to eq(3)
      end

      it "displays the textboxes in a table column" do
        expect(page.body).to include('<table>')
      end

      it "lets a user delete ingredients using checkboxes" do
        expect {
          check "#{Ingredient.first.id}-box"
          click_button "Save"
        }.to change { Ingredient.all.count }.by(-1)
      end

      it "lets a user delete multiple ingredients using checkboxes" do
        expect {
          check "#{Ingredient.first.id}-box"
          check "#{Ingredient.last.id}-box"
          click_button "Save"
        }.to change { Ingredient.all.count }.by(-2)
      end

      it "does not let a user blank out an existing ingredient" do
        fill_in("#{Ingredient.first.id}-field", with: "")  
        click_button "Save"
        expect(page.body).to include("Edit Your Ingredients")
        expect(page.body).to include("You cannot leave an existing ingredient blank. To delete ingredients, use the checkboxes.")
        expect(Ingredient.all.count).to eq(3)
      end
    end
  end


  describe "show ingredient action" do

    context "logged out" do
      it "does not let a user view an ingredient show page if logged out" do
        user = UserHelper.create_user
        ingredient = UserHelper.create_parsley(user)
        get "/ingredients/#{ingredient.id}"

        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_response.status).to eq(200)        
        expect(last_response.body).to include("Welcome")
      end
    end

    context "logged in" do
      before do
        user = User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
        post '/login', { username: "becky567", password: "kittens" }

        parsley = Ingredient.create(name: 'parsley', user_id: user.id)
      end
      
      it "lets the user access the ingredient show page if logged in" do
        get "/ingredients/#{ingredient.id}"
        expect(last_response.body).to include(ingredient.name)
      end

      it "lists all the users who have this ingredient" do
        
      end
    end

  end

end
