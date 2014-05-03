class Attribute < ActiveRecord::Base
  has_many :attribute_values
  has_many :people_events_attributes
  cattr_reader :per_page
  @@per_page = 10

  def add( event, person, value, notes )
    att = PeopleEventsAttribute.new
    att.person = person
    att.event = event
    att.attribute = self
    att[:value] = value
    att[:notes] = notes
    att.save
    event.save
    self.save
    return att
  end

  def add_order( order, value, notes )
    att = OrdersAttribute.new
    att.order = order
    att.attribute = self
    att[:value] = value
    att[:notes] = notes
    att.save
    event.save
    self.save
  end
end
