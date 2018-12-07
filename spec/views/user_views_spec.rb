require 'spec_helper'
require 'pry'

describe 'Views' do
  describe "Layout" do
    it "includes a header" do
      get '/index'
      expect(page.body).to include("Lend Me Some Sugar")
      expect(page.body).to include("Users")
      expect(page.body).to include("Browse Ingredients")
      expect(page.body).to include("Search Ingredients")
    end
  end

  describe "home page" do
    it "includes a link to sign up" do
      get '/'
      expect(page.body).to include("Sign Up")
    end
    
    it "includes a form to log in" do
      get '/'
      expect(page).to have_field(:name)
      expect(page).to have_field(:password)
    end
    
  end

end