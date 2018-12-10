class UserController < ApplicationController

  # Welcome action
  get '/' do
    erb :welcome
  end

  # Index Action
  get '/users' do
    @users = User.all
    erb :'/users/index'
  end
  
  # New Action
  get '/users/new' do
    @ingredients = Ingredient.all
    erb :'/users/new'
  end
  
  # Create Action
  post '/users' do
    user = User.create(params['user'])

    user.ingredients << Ingredient.create(name: params['ingredient_name']) unless params['ingredient_name'].empty?
    user.save
    redirect "users/#{user.id}"
  end
  
  # Show Action
  get '/users/:id' do
    @user = User.find(params[:id])
    erb :'/users/show'
  end
  
  # Edit Action
  get '/users/:id/edit' do
    @user = User.find(params[:id])
    @ingredients = Ingredient.all
    erb :'/users/edit'
  end
  
  # Patch Action
  patch '/users/:id' do
    params[:song_info]['ingredient_ids'].clear if !params[:user].keys.include?('ingredient_ids')
    user = User.find(params[:id])
    user.update(params['user'])

    user.ingredients << Ingredient.create(name: params['ingredient_name']) unless params['ingredient_name'].empty?
    user.save
    redirect "users/#{user.id}"
  end
  
  # Delete Action
  delete '/users/:id' do
    user = User.find(params[:id])
    user.delete
  end
  
end