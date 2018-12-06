class UserHelper
  def self.sign_up_user
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params  
  end
  
  def self.create_user
    user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  end

  def self.create_user_and_click_login
    self.create_user
    visit '/'
    fill_in(:username, :with => "becky567")
    fill_in(:password, :with => "kittens")
    click_button 'Log In'
  end

  def self.create_and_login_user
      self.create_user
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params    
  end
  
end