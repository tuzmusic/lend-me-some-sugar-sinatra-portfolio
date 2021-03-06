class ApplicationController < Sinatra::Base
    
  register Sinatra::ActiveRecordExtension
  
  configure do
    enable :sessions
    set :session_secret, "sugar_secret"
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  def current_user
    User.find(session[:id])
  end
end