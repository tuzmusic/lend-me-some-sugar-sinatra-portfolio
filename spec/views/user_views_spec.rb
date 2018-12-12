require 'spec_helper'
require 'pry'

describe 'Views' do
  describe "Layout" do
    xit "includes a header" do
      get '/index'
      expect(page.body).to include("Lend Me Some Sugar")
      expect(page.body).to include("Users")
      expect(page.body).to include("Browse Ingredients")
      expect(page.body).to include("Search Ingredients")
    end
  end

  describe "home page" do
    it "includes a link to sign up" do
      visit '/'
      expect(page.body).to include("sign up")
    end
    
    it "includes a form to log in" do
      visit '/'
      expect(page).to have_field(:username)
      expect(page).to have_field(:password)
    end
    
  end

end