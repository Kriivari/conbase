class Programitem < ActiveRecord::Base
  belongs_to :program
  belongs_to :location
  has_many :line_items
  cattr_reader :per_page
  @@per_page = 10

  def fullname
    if name && name.length > 0
      #Filter out duplicates like 'Pukukilpailu: Pukukilpailu - ilmoittautuminen'
      return name if name.include? program.name

      return program.name + ": " + name
    end
    return program.name
  end

  def fulldescription
    if description && description.length > 0
      return description if description.include? program.description
      return program.description + "\n\n" + description
    end
    return program.description
  end

  def validate
    unless start_time && end_time && start_time < end_time
      errors.add(:start_time, "Alku- tai loppuaika puuttuu tai loppuaika ei ole alkuajan jälkeen.")
    end
    conf = self.conflict
    if conf
      errors.add(:location, "Päällekäinen varaus! " + conf.program.name)
    end
  end

  def conflict
    conflict = Programitem.find_by_sql(["select programitems.* from programitems where location_id=? and program_id in (select id from programs where event_id=?) and ((start_time<=? and end_time>?) or (start_time<? and end_time>?)) and location_id in (select id from locations where event_id=?)", location_id, program.event.id, start_time, start_time, end_time, end_time, program.event.id])
    if conflict != nil && conflict.length > 0 && conflict[0].id != id 
      if self.location.multiple
	return nil
      else
	return conflict[0]
      end
    end
    return nil
  end

  def change
    changed = self.program.updated_at
    if changed == nil
      if self.updated_at == nil
        return nil
      else
        return self.updated_at
      end
    else
      if self.updated_at == nil
        return changed
      else
        if self.updated_at > changed
          return self.updated_at
        else
          return changed
        end
      end
    end
  end
end
