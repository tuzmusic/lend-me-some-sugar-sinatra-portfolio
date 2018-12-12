require 'spec_helper'
require_relative './spec_helpers'
require 'pry'

describe "show ingredient action" do

    context "logged out" do
      it "does not let a user view an ingredient show page if logged out" do
        user = User.create(username: "becky567", email: "starz@aol.com", password: "kittens")
        ingredient = Ingredient.create(name: 'parsley', user_id: user.id)

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

        Ingredient.create(name: 'parsley', user_id: user.id)
      end
      
      it "is accessed by a slug" do
        get "/ingredients/#{Ingredient.first.slug}"
        expect(last_response.body).to include(Ingredient.first.name)
      end
      
      it "searches for the first ingredient that matches the slug" do
        Ingredient.create(name: 'parsley', user_id: User.first.id)
        Ingredient.create(name: 'parsley', user_id: User.first.id)
        Ingredient.create(name: 'parsley', user_id: User.first.id)
        
        get "/ingredients/parsley"
        # not sure how to test the state of this instance variable
      end

      it "gives an error message if no ingredients match the slug" do
        get '/ingredients/asdfgh'
        expect(last_response.body).to include("No ingredient called 'asdfgh' could be found.")
      end

      it "shows the name of the ingredient" do
        get "/ingredients/#{Ingredient.first.slug}"
        expect(last_response.body).to include(Ingredient.first.name)
      end

      it "lists all the users who have an ingredient with the same name" do
        ["becky566","becky568","becky569"].each do |name|
          user = User.create(username: name, email: "starz@aol.com", password: "kittens")
          user.ingredients << Ingredient.create(name: 'cumin')
          user.ingredients << Ingredient.create(name: 'radishes')
          user.save
        end

        get "/ingredients/cumin"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('becky566')
        expect(last_response.body).to include('becky568')
        expect(last_response.body).to include('becky569')
      end

      it "finds the ingredient even if it's cased differenly" do
        ["becky566","becky568","becky569"].each do |name|
          User.create(username: name, email: "starz@aol.com", password: "kittens")
        end
        get "/ingredients/cumin"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('becky566')
        expect(last_response.body).to include('becky568')
        expect(last_response.body).to include('becky569')
      end

      it "includes links to each user's show page" do
        ["becky566","becky568","becky569"].each do |name|
          User.create(username: name, email: "starz@aol.com", password: "kittens")
        end
        get "/ingredients/cumin"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('users/becky566')
        expect(last_response.body).to include('users/becky568')
        expect(last_response.body).to include('users/becky569')
        
      end

      it "does not list users who don't have the ingredient" do
        parsley = Ingredient.first
        ["becky566","becky568","becky569"].each do |name|
          user = User.create(username: name, email: "starz@aol.com", password: "kittens")
          user.ingredients << Ingredient.create(name: 'cumin')
          user.save
        end
        get "/ingredients/parsley"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('becky567')
        expect(last_response.body).to_not include('becky566')
        expect(last_response.body).to_not include('becky568')
        expect(last_response.body).to_not include('becky569')
      end
    end

  end