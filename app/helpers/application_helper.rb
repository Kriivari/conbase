# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def find_groups
    if verify
      return @event.persongroups.sort{|g1,g2| g1.name <=> g2.name}
    end
    groups = []
    @event.persongroups.each {
      |group|
      group.visible && groups << group
    }
    return groups.sort{|g1,g2| g1.name <=> g2.name}
  end

  def find_visible_groups
    groups = []
    @event.persongroups.each {
        |group|
      group.visible && groups << group
    }
    return groups.sort{|g1,g2| g1.name <=> g2.name}
  end

  def verify
    if Person.first(:conditions => ["id=? and id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where name='Conitea' and event_id=?) and status = -1)", session[:user_id], @event])
      return true
    end
    return false
  end

  def self.reference(prefix,object)
    return refnumber(prefix.to_s + object.id.to_s)
  end

  def self.refnumber(orig)
    original = orig.to_s
    multiplier = 7
    sum = 0
    original.reverse.chars.each {|char|
      sum = sum + multiplier * char.to_i
      if multiplier == 7
	      multiplier = 3
      elsif multiplier == 3
	      multiplier = 1
      else
	      multiplier = 7
      end
    }
    last = sum % 10
    if last == 10 || last == 0
      last = 0
    else
      last = 10 - last
    end
    return original + last.to_s 
  end

  def yesno( game, grp )
    if game.programgroups.include?( grp )
      return "Kyllä / Yes"
    end
    return "Ei / No"
  end

end
