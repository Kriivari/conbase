class OrdersAttribute < ActiveRecord::Base
  belongs_to :order
  belongs_to :attribute
  cattr_reader :per_page
  @@per_page = 10
end
