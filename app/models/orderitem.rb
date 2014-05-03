class Orderitem < ActiveRecord::Base
  belongs_to :order
  belongs_to :statusname, :class_name => "Statusname", :foreign_key => "status"
end
