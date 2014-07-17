class Program < ActiveRecord::Base
  belongs_to :event
  has_many :programs_organizers
  has_many :programitems
  has_many :program_languages
  has_many :programs_events_attributes
  has_many :orders
  has_and_belongs_to_many :programgroups, :join_table => 'programs_programgroups'
  belongs_to :statusname, :class_name => "Statusname", :foreign_key => "status"
  cattr_reader :per_page
  @@per_page = 50

  def to_s
    name
  end

  def all_organizers
    if self.programs_organizers == nil
      return ""
    end
    ret = ""
    self.programs_organizers.each { |organizer|
      if organizer.person != nil
	if ret.length > 0
	  ret = ret + ", "
	end
        ret = ret + organizer.person.name
      end
    }
    return ret
  end

  def main_organizer
    if self.programs_organizers == nil
      return nil
    end

    ret = nil
    self.programs_organizers.each { |organizer|
      ret = organizer.person
      if organizer.statusname == nil || organizer.statusname.name == "Paajarjestaja"
        return organizer.person
      end
    }
    return ret
  end

  def genre
    self.programs_events_attributes.each { |a|
      if a.attribute.name == "Genre"
        return a.value
      end
    }
    return nil
  end

  def showgroups
    ret = ""
    self.programgroups.each{ |group|
      if group.name != nil && ! ret.include?( group.name )
	ret = ret + group.name + " "
      end
    }
    self.programs_events_attributes.each{ |att|
      ret = ret + att.value
    }
    return ret
  end

  def namebylang( language )
    self.program_languages.each { |lang|
      if lang.language == language
	return lang.name
      end
    }
    return self.name
  end

  def descriptionbylang( language )
    self.program_languages.each { |lang|
      if lang.language == language
	return lang.description
      end
    }
    return self.description
  end

  def notesbylang( language )
    self.program_languages.each { |lang|
      if lang.language == language
	return lang.publicnotes
      end
    }
    return self.publicnotes
  end
end
