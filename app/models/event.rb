class Event < ActiveRecord::Base
  has_many :locations
  has_many :personeventattributes
  has_many :persongroups
  has_many :programs
  has_many :orders
  has_many :exhibitors
  has_many :notes
  cattr_reader :per_page
  @@per_page = 10

  def to_s
    self.name + " " + self.year.to_s
  end

  def organizer_count
    people = Person.find_by_sql(["select distinct people.* from people where id in (select person_id from people_persongroups where status=-1 and persongroup_id in (select id from persongroups where event_id=? and insurance=true))", self.id])
    return people.size
  end

  def underage_organizer_count
    people = Person.find_by_sql(["select distinct people.* from people where (birthyear is null or (date_part('year', current_date) - birthyear) < 19) and id in (select person_id from people_persongroups where status=-1 and persongroup_id in (select id from persongroups where event_id=? and insurance=true))", self.id])
    return people.size
  end

  def program_organizer_count
    people = Person.find_by_sql(["select distinct people.* from people where id in (select person_id from programs_organizers where program_id in (select id from programs where status = -1 and event_id = ? and id in (select program_id from programs_programgroups where programgroup_id in (4,6,7,8,9))))", self.id])
    return people.size
  end

  def game_organizer_count
    people = Person.find_by_sql(["select distinct people.* from people where id in (select person_id from programs_organizers where program_id in (select id from programs where status = -1 and event_id = ? and id in (select program_id from programs_programgroups where programgroup_id in (1,2,3,5,12))))", self.id])
    return people.size
  end

  def program_count
    programs = Program.find_by_sql(["select distinct programs.* from programs where status = -1 and event_id = ? and id in (select program_id from programs_programgroups where programgroup_id in (4,6,7,8,9))", self.id])
    return programs.size
  end

  def game_count
    programs = Program.find_by_sql(["select distinct programs.* from programs where status = -1 and event_id = ? and id in (select program_id from programs_programgroups where programgroup_id in (1,2,3,5,12))", self.id])
    return programs.size
  end

  def ticket_count
    threedays = 0
    oneday = 0
    people = Person.find_by_sql(["select distinct people.* from people where id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id=? and days>0)) or id in (select person_id from people_events_attributes, attributes where event_id=? and attributes.id=attribute_id and name='Ranneke')", self.id, self.id])
    for person in people
      if person.max_days(@event) == 3
	threedays = threedays + 1
      else
	oneday = oneday + 1
      end
    end
    return people.size.to_s + ' ' + threedays.to_s + '/' + oneday.to_s
  end

  def food_count
    foods = Person.find_by_sql(["select distinct people.* from people where id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id=? and food>0))", self.id])
    return foods.size
  end

  def times
    times = []
    start = starttime - 3*60*60
    while start < endtime
      times << start.strftime("%a%H")
      start = start + 3600
    end
    return times
  end
end
