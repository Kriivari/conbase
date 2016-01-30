class Persongroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :mailinglist
  has_many :people_persongroups 
  cattr_reader :per_page
  @@per_page = 10

  def members
    m = []
    g = []
    self.people_persongroups.each{ |group|
      if ! m.include?( group.person ) && group.status == -1
        m << group.person
        g << group
      end
    }
    return g
  end

  def size
    return members.length
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
