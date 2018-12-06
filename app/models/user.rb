class User < ActiveRecord::Base 
  has_many :ingredients
end