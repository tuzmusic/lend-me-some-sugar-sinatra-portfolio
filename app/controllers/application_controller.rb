class ApplicationController < Sinatra::Base
    
  register Sinatra::ActiveRecordExtension
  
  configure do
    enable :sessions
    set :session_secret, "sugar_secret"
    set :public_folder, 'public'
    set :views, 'app/views'
  end


  get '/' do
    erb :index
  end
end