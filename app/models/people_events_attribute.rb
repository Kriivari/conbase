class PeopleEventsAttribute < ActiveRecord::Base
  belongs_to :person
  belongs_to :event
  belongs_to :attribute

  def self.by_name(event,name,person)
    attribute = ::Attribute.find_by_name(name)
    PeopleEventsAttribute.where("event_id=? and person_id=? and attribute_id=?", event.id, person.id, attribute.id)
  end
end
