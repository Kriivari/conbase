class PeoplePersongroup < ActiveRecord::Base
  belongs_to :person
  belongs_to :persongroup
  belongs_to :statusname, :class_name => "Statusname", :foreign_key => "status"

  def after_save
    if self.statusname == nil
      return
    end
    if self.statusname.id == -1 && self.persongroup.mailinglist != nil && ! mailinglist(self.persongroup.mailinglist.address, self.person.primary_email, true)
      logger.fatal("Cannot save")
    end
  end

  def before_destroy
    if self.statusname.id == -1 && self.persongroup.mailinglist != nil && ! mailinglist(self.persongroup.mailinglist.address, self.person.primary_email, false)
      logger.fatal("Cannot delete")
    end
  end

  def mailinglist( list, address, add )
    if address == nil
      return
    end
    command = "unsubscribe"
    if add
      command = "subscribe"
    end
    if address.rindex("example.com") == nil && address.rindex(".invalid") != address.length - 8
      unless system( Rails.configuration.mailing_list_client, command, list, address )
        logger.fatal("Unable to execute enemies-of-carlotta " + command + " --name=" + list + " " + address)
        return false
      end
    end
    return true
  end
end
