class IngredientController < ApplicationController

  # Index Action
  get '/ingredients' do
    @ingredients = Ingredient.all
    erb :'/ingredients/index'
  end
  
  # New Action
  get '/ingredients/new' do
    if session[:id]
      @users = User.all
      erb :'/ingredients/new'
    else 
      redirect '/'
    end
  end
  
  # Create Action
  post '/ingredients' do
    user = User.find(session[:id])

    params[:ingredients].each do |ingredient|
      next if ingredient[:name].empty?
      ingredient = Ingredient.create(ingredient)
      ingredient.user = user
      ingredient.save
    end

    redirect "/users/#{user.slug}"
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