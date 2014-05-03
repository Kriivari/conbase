class Product < ActiveRecord::Base
  attr_accessible :name, :active

  has_many :product_types
end
