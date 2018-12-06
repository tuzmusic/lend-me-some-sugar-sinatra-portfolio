class SpecHelper
  def self.sign_up_user
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params  
  end
  
end