class Ingredient < ActiveRecord::Base 
  belongs_to :user

  require_relative './concerns/slugifiable'
  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end