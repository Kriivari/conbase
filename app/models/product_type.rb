class ProductType < ActiveRecord::Base
  attr_accessible :name, :price, :active

  belongs_to :product
  has_and_belongs_to_many :purchases
  has_and_belongs_to_many :exhibitors

  def fullname
    return self.product.name + " " + self.name
  end
end
