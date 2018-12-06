class IngredientController < ApplicationController

  # Index Action
  get '/ingredients' do
    @ingredients = Ingredient.all
    erb :'/ingredients/index'
  end
  
  # New Action
  get '/ingredients/new' do
    @users = User.all
    erb :'/ingredients/new'
  end
  
  # Create Action
  post '/ingredients' do
    ingredient = Ingredient.create(params['ingredient'])
    ingredient.user = User.create(name: params['user_name']) unless params['user_name'].empty?

    ingredient.save
    redirect "ingredients/#{ingredient.id}"
  end
  
  # Show Action
  get '/ingredients/:id' do
    @ingredient = Ingredient.find(params[:id])
    erb :'/ingredients/show'
  end
  
  # Edit Action
  get '/ingredients/:id/edit' do
    @ingredient = Ingredient.find(params[:id])
    @users = User.all
    erb :'/ingredients/edit'
  end
  
  # Patch Action
  patch '/ingredients/:id' do

    ingredient = Ingredient.find(params[:id])
    ingredient.update(params['ingredient'])
    ingredient.user = User.create(name: params['user_name']) unless params['user_name'].empty?

    ingredient.save
    redirect "ingredients/#{ingredient.id}"
  end
  
  # Delete Action
  delete '/ingredients/:id' do
    ingredient = Ingredient.find(params[:id])
    ingredient.delete
  end
  
end