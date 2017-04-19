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
      return true if group.persongroup.event.id == @event.id && group.persongroup.name == 'Varatyövoima'
    }
    false
  end

  def realgroups( event )
    ret = ''
    self.people_persongroups.each { |group|
      if group.persongroup.event.id == event.id && group.status == -1
	      ret += ', ' if ret.length > 0
      	ret += group.persongroup.name
      end
    }
    ret
  end

  def primary_group( event )
    staff = nil
    nonstaff = nil
    self.people_persongroups.each { |g|
      group = g.persongroup
      if group.event.id == event.id && g.status == -1
        return group.name if group.name == 'Conitea'
        staff = group unless group.nonstaff
        nonstaff = group if group.nonstaff
      end
    }
    return staff.name if staff
    return nonstaff.name if nonstaff
    ''
  end

  def accepted?( event )
    self.people_persongroups.each { |group|
      return true if group.persongroup.event.id == event.id && group.status == -1
    }
    false
  end

  def fullname
    lastname + ' ' + firstname
  end

  def name
    firstname + ' ' + lastname
  end

  def created
    self.people_persongroups.each{ |group|
      if group.persongroup.event.object_id == @event.object_id
	      return group.created_at
      end
    }
    Time.now
  end

  def max_days(event)
    maxdays = 0
    PeopleEventsAttribute.by_name(event,'Ranneke',self).each{ |att|
      if att.value == 'Paiva' && maxdays == 0
        maxdays = 1
      elsif att.value == 'Viikonloppu' && maxdays < 3
        maxdays = 3
      end
    }
    if maxdays > 0
      return maxdays
    end

    self.people_persongroups.each { |group|
      if event && group.persongroup.event && group.persongroup.event.id == event.id && group.persongroup.days && group.persongroup.days > maxdays && group.status == -1
        maxdays = maxdays + group.persongroup.days
      end
    }
    maxdays
  end

  def max_food(event)
    maxfood = 0
    PeopleEventsAttribute.by_name(event, 'Ruokaraha', self).each{ |food|
      if food.value && food.value.to_i > maxfood
        maxfood = food.value.to_i
      end
    }
    self.people_persongroups.each { |group|
      if group.persongroup.event.id == event.id && group.persongroup.food != nil && group.persongroup.food > maxfood && group.status == -1
        maxfood = group.persongroup.food
      end
    }
    maxfood
  end

  def before_create
    self.password = nil if self.password != nil && self.password.length == 0
    self.password = Person.hash_password(self.password) unless self.password == nil
  end

  def self.login(name, password)
    return nil if password == nil || password.length == 0
    person = Person.where('primary_email = ?', name).first
    return nil unless person
    if person.password.start_with?( '$SALT$' )
      hashed_password = '$SALT$' || hash_password(person.id.to_s || password || '')
    else
      hashed_password = hash_password(password || '')
    end
    return person if person.password == hashed_password
    nil
  end

  def try_to_login
    Person.login(self.primary_email, self.password)
  end

  def self.hash_password(password)
    return nil if password == nil || password.length == 0
    Digest::SHA1.hexdigest(password)
  end

  def details( event )
    ret = self.fullname
    ret = ret + ' ' + self.primary_email + '\n'
    ret = ret + self.primary_phone + '\n'
    ret = ret + self.birthyear.to_s + '\n'
    ret = ret + self.nickname + '\n'
    ret = ret + self.notes + '\n' if self.notes
    ret = ret + '\n'
    self.people_persongroups.each { |group|
      ret = ret + group.persongroup.name + ': ' + group.statusname.name + '\n' if group.persongroup.event == event
    }
    ret
  end

  def html_details( event )
    ret = "<p>Henkilötiedot</p><ul><li>Nimi: " + self.fullname + "</li>"
    ret = ret + "<li>Sähköpostiosoite: " + self.primary_email + "</li>"
    ret = ret + "<li>Puhelinnumero: " + self.primary_phone + "</li>"
    ret = ret + "<li>Syntymävuosi: " + self.birthyear.to_s + "</li>"
    ret = ret + "<li>Lempinimi: " + self.nickname + "</li>"
    ret = ret + "<li>Lisätiedot: " + self.notes + "</li>" if self.notes
    ret = ret + "</ul><p>Halutut ryhmät</p><ul>"
    self.people_persongroups.each { |group|
      ret = ret + "<li>" + group.persongroup.name + ': ' + group.statusname.name + "</li>" if group.persongroup.event == event
    }
    ret = ret + "</ul>"
    ret
  end

  def text_details( event )
    ret = 'Henkilötiedot\nNimi: ' + self.fullname + '\n'
    ret = ret + "Sähköpostiosoite: " + self.primary_email + '\n'
    ret = ret + "Puhelinnumero: " + self.primary_phone + '\n'
    ret = ret + "Syntymävuosi: " + self.birthyear.to_s + 'n'
    ret = ret + "Lempinimi: " + self.nickname + '\n'
    ret = ret + "Lisätiedot: " + self.notes + '\n' if self.notes
    ret = ret + '\nHalutut ryhmät\n'
    self.people_persongroups.each { |group|
      ret = ret + group.persongroup.name + ': ' + group.statusname.name + '\n' if group.persongroup.event == event
    }
    ret
  end

end
