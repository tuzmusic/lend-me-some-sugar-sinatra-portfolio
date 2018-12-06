class User < ActiveRecord::Base 
  has_many :ingredients
  has_secure_password
end