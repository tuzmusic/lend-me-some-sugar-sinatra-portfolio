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
  
  # Edit Action
  get '/ingredients/edit' do
    # binding.pry
    if session[:id]
      @user = User.find(session[:id])
      erb :'/ingredients/edit'
    else 
      redirect '/'
    end
  end
  
  # Patch Action
  patch '/ingredients' do

    params[:ingredients].each do |ingredient|
      ing = Ingredient.find(ingredient[:id])
      ing.update(ingredient)
      ing.save
    end

    redirect "users/#{current_user.slug}"
  end
  
  # Show Action
  get '/ingredients/:id' do
    @ingredient = Ingredient.find(params[:id])
    erb :'/ingredients/show'
  end
  
  # Delete Action
  delete '/ingredients/:id' do
    ingredient = Ingredient.find(params[:id])
    ingredient.delete
  end
  
end