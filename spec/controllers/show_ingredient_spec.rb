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