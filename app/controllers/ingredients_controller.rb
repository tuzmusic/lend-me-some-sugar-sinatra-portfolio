class IngredientController < ApplicationController

  # Index Action
  get '/ingredients' do
    @ingredients = Ingredient.all
    erb :'/ingredients/index'
  end
  
  # New Action
  get '/ingredients/new' do
    if session[:id]
      @user = User.find(session[:id])
      erb :'/ingredients/new'
    else 
      redirect '/'
    end
  end
  
  # Create Action
  post '/ingredients' do
    user = current_user

    params[:ingredients].each do |ingredient|
      next if ingredient[:name].empty?
      ingredient = Ingredient.create(ingredient)
      ingredient.user = user
      ingredient.save
    end

    redirect "/index"
  end
  
  # Edit Action
  get '/ingredients/edit' do
    if session[:id]
      @user = current_user
      erb :'/ingredients/edit'
    else 
      redirect '/'
    end
  end
  
  # Patch Action
  patch '/ingredients' do

    if params[:ingredients].any? { |i| i[:name].empty?}
      session[:flash] = "You cannot leave an existing ingredient blank. To delete ingredients, use the checkboxes."
      redirect 'ingredients/edit'
    else 
      params[:ingredients].each do |ingredient|
        ing = Ingredient.find(ingredient[:id])
        if ingredient[:delete]
          # this should reroute to the delete route, but it's not working.
          # call env.merge("REQUEST_METHOD" => 'delete',"PATH_INFO" => "/ingredients/#{ing.id}")
          ing.delete
        else
          ing.update(ingredient)
          ing.save
        end
      end  
      redirect "index"
    end

  end
  
  # Show Action
  get '/ingredients/:slug' do
    @ingredient = Ingredient.find_by_slug(params[:slug])

    if !session[:id]
      redirect '/'
    elsif !@ingredient
      "No ingredient called '#{params[:slug]}' could be found."
    else
      @users_with = User.all.select do |user|
        ings = user.ingredients.map {|i| i.name.downcase}
        ings.include?(params[:slug].downcase)
      end
      erb :'/ingredients/show'
    end
  end
  
  # Delete Action
  # we never actually get here
  delete '/ingredients/:id' do
    ingredient = Ingredient.find(params[:id])
    ingredient.delete
  end
  
end