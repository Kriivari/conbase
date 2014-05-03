class Order < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  has_many :orderitems
  has_many :orders_attributes
  belongs_to :statusname, :class_name => "Statusname", :foreign_key => "status"

  cattr_reader :per_page
  @@per_page = 10

  def change_status
    status = nil
    for item in self.orderitems
      if ! status
	      status = item.status
      elsif status != item.status
	      status = nil
	      break
      end
    end
    if status && status != self.status
      self.status = status
      self.save
    end
  end

  def total
    sum = 0
    for item in self.orderitems
      if item.cost
	      sum = sum + item.cost
      end
    end
    return sum
  end

  def maximum
    sum = 0
    for item in self.orderitems
      if item.maxcost
	      sum = sum + item.maxcost
      end
    end
    return sum
  end
end
