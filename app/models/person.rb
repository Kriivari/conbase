class Person < ActiveRecord::Base
  has_many :contacts
  has_many :people_persongroups
  has_many :people_events_attributes
  has_many :programs_organizers
  has_many :orders
  has_many :exhibitors
  cattr_reader :per_page
  @@per_page = 10

  def to_s
    fullname
  end

  def validate
    unless firstname
      errors.add(:firstname, "Etunimi puuttuu")
    end
    unless lastname
      errors.add(:lastname, "Sukunimi puuttuu")
    end
    unless primary_email && primary_email =~ /^\S+@\S+.\S+$/
      errors.add(:primary_email, "Sähköpostiosoite puuttuu tai ei ole laillinen osoite")
    end
  end

  def in_reserve_group?
    self.people_persongroups.each { |group|
      if group.persongroup.event.id == @event.id && ( group.persongroup.name == "Narikka" || group.persongroup.name == "Majoitus" || group.persongroup.name == "Lipunmyynti" || group.persongroup.name == "Kaubamaja" )
        return true
      end
    }
    return false
  end

  def realgroups( event )
    ret = ""
    self.people_persongroups.each { |group|
      if group.persongroup.event.id == event.id && group.status == -1
	if ret.length > 0
	  ret += ", "
	end
	ret += group.persongroup.name
      end
    }
    return ret
  end

  def accepted?( event )
    self.people_persongroups.each { |group|
      if group.persongroup.event.id == event.id && group.status == -1
        return true
      end
    }
    return false
  end

  def fullname
    return lastname + " " + firstname
  end

  def name
    return firstname + " " + lastname
  end

  def created
    for group in self.people_persongroups
      if group.persongroup.event.id == @event.id
	      return group.created_at
      end
    end
    return Time.now
  end

  def max_days(event)
    maxdays = 0
    for att in PeopleEventsAttribute.by_name(event,"Ranneke",self)
      if att.value == "Paiva" && maxdays == 0
        maxdays = 1
      elsif att.value == "Viikonloppu" && maxdays < 3
        maxdays = 3
      end
    end
    if maxdays > 0
      return maxdays
    end

    self.people_persongroups.each { |group|
      if group.persongroup.event.id == event.id && group.persongroup.days && group.persongroup.days > maxdays && group.status == -1
        maxdays = maxdays + group.persongroup.days
      end
    }
    return maxdays
  end

  def max_food(event)
    maxfood = 0
    for food in PeopleEventsAttribute.by_name(event, "Ruokaraha", self)
      if food.value && food.value.to_i > maxfood
        maxfood = food.value.to_i
      end
    end
    self.people_persongroups.each { |group|
      if group.persongroup.event.id == event.id && group.persongroup.food != nil && group.persongroup.food > maxfood && group.status == -1
        maxfood = group.persongroup.food
      end
    }
    return maxfood
  end

  def before_create
    if self.password != nil && self.password.length == 0
      self.password = nil
    end
    if self.password != nil
      #self.password = "$SALT$" || Person.hash_password(self.id.to_s || self.password)
      self.password = Person.hash_password(self.password)
    end
  end

  def self.login(name, password)
    if password == nil || password.length == 0
      return nil
    end
    person = Person.where("primary_email = ?", name).first
    unless person
      return nil
    end
    if person.password.start_with?( "$SALT$" )
      hashed_password = "$SALT$" || hash_password(person.id.to_s || password || "")
    else
      hashed_password = hash_password(password || "")
    end
    if person.password == hashed_password
      return person
    end
    return nil
  end

  def try_to_login
    Person.login(self.primary_email, self.password)
  end

  def self.hash_password(password)
    if password == nil || password.length == 0
      return nil
    end
    logger.info("Hashing to " + Digest::SHA1.hexdigest(password))
    Digest::SHA1.hexdigest(password)
  end

  def available(time)
    return true
  end

  def scheduled(time)
    return ""
  end

  def availability_color(time)
    return "Lime"
  end

  def details( event )
    ret = self.fullname
    ret = ret + " " + self.primary_email + "\n"
    ret = ret + self.primary_phone + "\n"
    ret = ret + self.birthyear.to_s + "\n"
    ret = ret + self.nickname + "\n"
    if self.notes
      ret = ret + self.notes + "\n"
    end
    ret = ret + "\n"
    self.people_persongroups.each { |group|
      if group.persongroup.event == event
        ret = ret + group.persongroup.name + ": " + group.statusname.name + "\n"
      end
    }
    return ret
  end
end
