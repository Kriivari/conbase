class Persongroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :mailinglist
  has_many :people_persongroups 
  cattr_reader :per_page
  @@per_page = 10

  def size
    count = 0
    self.people_persongroups.each { |group|
      if group != nil && group.status != nil && group.status.object_id > -2
	count = count + 1
      end
    }
    return count
  end

  def ingroup( person )
    for group in person.people_persongroups
      if group.persongroup == self
	return true
      end
    end
    return false
  end

  def add( person, status )
    group = PeoplePersongroup.new
    group.person = person
    group.persongroup = self
    group.statusname = status
    group.save
    self.save
  end
end
