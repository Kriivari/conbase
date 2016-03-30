class StaffController < Application
  before_filter :authorize, :except => [:new, :create, :tshirt, :ordershirt]
#  before_filter :authorize, :except => [:login]

  def index
    @groups = Persongroup.all(:conditions => ["event_id=?", @event.id], :order => "name")
  end

  def tshirt
    @person = Person.new
    @shirttypes = ProductType.all(:conditions => ["product_id=?", Product.first(:conditions => ["name='Staff-paita'"]).id]).sort{ |a,b| a.name <=> b.name }
    begin
      render(:layout => "layouts/" + @event.name.to_s + "_staff" )
    rescue Exception
      render
    end
  end

  def ordershirt
    @event = Event.find_by_id(params[:event])
    @person = Person.find_by_primary_email(params[:person][:primary_email])
    if @person == nil
      @person = Person.new
      @person.errors.add(:primary_email, "Sähköpostiosoitetta ei tunnistettu")
      begin
        render(:layout => "layouts/" + @event.name.to_s + "_staff" )
      rescue Exception
        render
      end
      return
    end
    unless @person.accepted?( @event )
      @person.errors.add(:base, "Sinua ei ole vahvistettu työvoimaan!")
      begin
        render(:layout => "layouts/" + @event.name.to_s + "_staff" )
      rescue Exception
        render
      end
      return
    end

    @tshirt = ""
    if params[:product]
      tshirt = ProductType.find(params[:product][:id])
      purchase = Purchase.new
      purchase.person = @person
      purchase.event = @event
      purchase.product_types << tshirt
      purchase.details = params[:shirttext]
      @tshirt = tshirt.fullname + ", teksti: " + params[:shirttext]
      baseprice = tshirt.price
      purchase.save
      if params[:shirttext] == nil || params[:shirttext].length == 0
	      baseprice = baseprice - 3
      end
      if @event.footer && baseprice > 0
	      basename = tshirt.fullname
	      realbody = @event.footer
	      realbody = realbody.gsub("%PRICE%",baseprice.to_s.sub(".",","))
	      realbody = realbody.gsub("%REFERENCE%",purchase.reference)
        if params[:shirttext] && params[:shirttext].length > 0
	        realbody = realbody.gsub("%SHIRTDETAILS%", basename + "; Nimikointi: " + params[:shirttext])
	      else
	        realbody = realbody.gsub("%SHIRTDETAILS%", basename + "; Ei nimikointia")
	      end
	      GenericMailer.email(@event, "tyovoima@ropecon.fi", @person.primary_email, "paitatilauksen maksuohjeet", realbody).deliver
      end
    end

    @person.save
    begin
      render(:layout => "layouts/" + @event.name.to_s + "_staff" )
    rescue Exception
      render
    end
  end

  def new
    @person = Person.new
    begin
      render(:layout => "layouts/" + @event.name.to_s + "_staff" )
    rescue Exception
      render
    end
  end

  def create
    if params[:spammer] && params[:spammer] != ""
      redirect_to :action => "new"
      return
    end
    @oldgroups = ""
    @newgroups = ""
    @person = Person.find_by_primary_email(params[:person][:primary_email])
    if @person != nil
      @person.primary_phone = params[:person][:primary_phone]
      @person.birthyear = params[:person][:birthyear]
      @person.notes = params[:person][:notes] + "; " + params[:kuulit] + "; " + params[:kuulut]
      @person.nickname = params[:person][:nickname]
      @person.photo_url = params[:person][:photo_url]
    else
      @person = Person.create(params[:person])
      @person.notes = params[:person][:notes] + "; " + params[:kuulit] + "; " + params[:kuulut]
    end

    unless @event.registration
      @person.errors.add(:primary_phone, "Ilmoittautumiset eivät ole vielä auki.")
      begin
        render(:layout => "layouts/" + @event.name.to_s + "_staff" )
      rescue Exception
        render
      end
      return
    end


    if params[:person][:primary_phone] == nil || params[:person][:birthyear] == nil || params[:person][:primary_phone].length == 0 || params[:person][:birthyear].length == 0
      @person.errors.add(:primary_phone, "Puhelinnumero tai syntymäaika puuttuu")
      begin
        render(:layout => "layouts/" + @event.name.to_s + "_staff" )
      rescue Exception
        render
      end
      return
    end

    @oldgroups = savegroups( params[:oldgroups], "Vanha" )
    if verify
      @newgroups = savegroups( params[:groups], "Vahvistettu" )
    else
      @newgroups = savegroups( params[:groups], "Toive" )
    end

    @extra = ""
    extra = params[:extra]
    if extra != nil && extra == "yes"
      group = Persongroup.first(:conditions => "name='Varatyövoima' and event_id in (select id from events where ispublic=true)")
      status = Statusname.find_by_name("Toive")
      group.add( @person, status )
      @extra = "Haluat 12h töitä."
    end

    toomuch = params[:toomuch]
    if toomuch != nil && toomuch == "yes"
      group = Persongroup.first(:conditions => "name='Ylityövoima' and event_id in (select id from events where ispublic=true)")
      status = Statusname.find_by_name("Toive")
      group.add( @person, status )
      @extra = "Haluat yli 12h töitä."
    end

    @jv = ""
    jv = params[:jvnumber]
    if jv != nil && jv != ""
      @jv = jv
      jvv = Attribute.first(:conditions => "name='JV-kortti'")
      att = PeopleEventsAttribute.first(:conditions => ["person_id=? and event_id=? and attribute_id=?", @person.id, @event.id, jvv.id])
      if att == nil
        jvv.add( @event, @person, "K", jv )
      else
        att[:value] = "K"
        att[:notes] = jv
        att.save
      end
    end

    begin
      @person.save
    rescue
      Iconv.conv('utf-8','ISO-8859-1',@person.notes)
      @person.save
    end
    realbody = @event.registration
    realbody = realbody + "\n\n"
    realbody = realbody + @person.details( @event )
    StaffMailer.confirm(realbody, "tyovoima@ropecon.fi", @person.primary_email, nil, @event.name + " - ilmoittautuminen").deliver
    begin
      render(:layout => "layouts/" + @event.name.to_s + "_staff" )
    rescue Exception
      render
    end
  end

  def list
    @filter = params[:filter] || "%"
    if params[:group] != nil
      @filter = params[:group]
      @staffs = Person.find_by_sql(["select people.* from people, persongroups, people_persongroups where person.id=people_persongroups.id and (people_persongroups.status<-9 or people_persongroups.status=-2) and persongroup_id=? order by people.id", @filter])
    else
      @staffs = Person.find_by_sql(["select people.* from people, persongroups, people_persongroups, events where persongroups.name like ? and people.id=people_persongroups.person_id and persongroups.id=people_persongroups.persongroup_id and persongroups.event_id=events.id and events.ispublic=true and people_persongroups.status<-1 and persongroups.nonstaff=false and persongroups.visible=true and people.id not in (select person_id from people_persongroups,persongroups,events where status>-2 and people_persongroups.persongroup_id=persongroups.id and persongroups.nonstaff=false and events.id=persongroups.event_id and events.ispublic=true) and people.id not in (select person_id from exhibitors,events where event_id=events.id and events.ispublic=true) order by people.id", @filter])
      empties = Person.find_by_sql(["select distinct people.* from people where (created_at>? or modified_at>?) and people.id not in (select person_id from people_persongroups where status>-3 and persongroup_id in (select id from persongroups where event_id=?)) and people.id not in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id!=?)) and people.id not in (select person_id from exhibitors where event_id=?) order by lastname, firstname", 100.days.ago, 100.days.ago, @event.id, @event.id, @event.id])
      for empty in empties
        @staffs << empty
      end
    end

    newstaff = []
    last = nil
    for staff in @staffs
      if last == nil || staff.id != last.id
	newstaff << staff
      end
      last = staff
    end
    @staffs = newstaff
    @staffs.sort! { |a,b| a.created <=> b.created }

    @duplicates = {}
    for staff in @staffs
      duplicate = Person.find_by_sql(["select distinct people.* from people where firstname = ? and lastname = ? and id != ?", staff.firstname, staff.lastname, staff.id])
      if duplicate != nil
        @duplicates[staff.id] = duplicate
      end
    end

    @count = @staffs.size
    @queuegroup = Persongroup.where( "name='Jono' and event_id=?", @event.id ).first
  end

  def confirmed(body)
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    namelist = ""
    pgroup = Persongroup.find(params[:admin][:primarygroup])
    for checked in params[:checked].keys
      groupfound = false
      person = Person.find(checked)
      for persongroup in person.people_persongroups
        if ! groupfound && persongroup.persongroup.id == pgroup.id && persongroup.status == -2
          groupfound = true
	  begin
	    persongroup.status = -1
	    persongroup.save
	    if persongroup.persongroup.mailinglist != nil && person.primary_email.rindex("example.com") == nil && person.primary_email.rindex(".invalid") != person.primary_email.length - 8
	      unless system( Rails.configuration.mailing_list_client + " subscribe " + persongroup.persongroup.mailinglist.address + " " + person.primary_email )
		logger.fatal( "Unable to execute " + Rails.configuration.mailing_list_client + " " + "subscribe" + " " + persongroup.persongroup.mailinglist.address + " " + person.primary_email )
		flash["email" + person.id.to_s] = "Virhe lisättäessä henkilöä postilistalle " + persongroup.persongroup.mailinglist.name
	      end
	    end
	  rescue Exception
	    logger.fatal("Unable to update person " + person.primary_email)
	    flash["email" + person.id.to_s] = "Henkilön vaihtaminen ryhmään ei onnistunut"
	  end
        end
      end
      unless groupfound
        pgroup.add( person, Statusname.find_by_name( "Vahvistettu" ) )
        if pgroup.mailinglist && persongroup
          unless system( Rails.configuration.mailing_list_client + " subscribe " + pgroup.mailinglist.address + " " + person.primary_email )
	    logger.fatal( "Unable to execute (2) " + Rails.configuration.mailing_list_client + " subscribe " + pgroup.mailinglist.address + " " + person.primary_email )
            flash["email" + person.id.to_s] = "Virhe lisättäessä henkilöä postilistalle " + persongroup.persongroup.mailinglist.name
          end
        end
      end
      person.save
      pgroup.save
      StaffMailer.confirm(body, "tyovoima@ropecon.fi", person.primary_email, nil, @event.name + " - tervetuloa tapahtumaan").deliver

      flash["add" + person.id.to_s] = person.firstname + " " + person.lastname + " lisätty ryhmään " + pgroup.name
      namelist = namelist + person.fullname + ", "
    end

    if pgroup.adminemail != nil
      StaffMailer.confirm("Lisätty ryhmään " + pgroup.name + ": " + namelist, "tyovoima@ropecon.fi", pgroup.adminemail, pgroup.adminemail, "Ryhmään lisätty henkilöitä").deliver
    end

    redirect_to :action => 'list'
  end

  def multiconfirm
    if params[:commit] == 'Vahvista'
      email = params[:email][:text]
      if email && email.size > 2
        confirmed(email)
        return
      else
        flash["eiviestia"] = "Et laittanut lainkaan viestiä!"
      end
    end
    @checked = params[:checked]
    if params[:admin] == nil
      flash["eivalintaa"] = "Et valinnut ryhmää!"
      redirect_to :action => 'list'
      return
    end
    @admin = {:primarygroup => params[:admin][:primarygroup]}
    @persongroup = Persongroup.find(params[:admin][:primarygroup])
    if @persongroup.mailinglist != nil
      @email = @persongroup.mailinglist.template
    end
    list
    render :template => "staff/list"
  end

  def show
    @staff = Person.find(params[:id])
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    Person.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def remove_signup
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    person = Person.find(params[:id])
    if person
      person.people_persongroups.each { |group|
        if group.persongroup.event.id == @event.id && ( group.status == -2 || group.status == -3 )
          group.destroy
        end
      }
      person.save
    end
    redirect_to :back
  end

  def return
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    group = PeoplePersongroup.find(params[:groupid])
    group.status = -2
    group.save
    redirect_to :back
  end

  def showbygroup
    @group = Persongroup.find(params[:id])
    @groups = @group.members
    @groups.sort!{|g1,g2| g1.person.lastname <=> g2.person.lastname}
  end

  def menu
  end

  def bygroupandattribute( groupfield, attributename )
    attribute = Attribute.first(:conditions => "name='" + attributename+ "'")
    return Person.find_by_sql(["select distinct people.* from people where id in (select person_id from people_persongroups where status=-1 and persongroup_id in (select id from persongroups where event_id=? and " + groupfield + ">0)) or id in (select person_id from people_events_attributes where event_id=? and attribute_id=?) order by lastname,firstname", @event.id, @event.id, attribute.id])
  end

  def tickets
    @staffs = bygroupandattribute( "days", "Ranneke" )
  end

  def foods
    @staffs = bygroupandattribute( "food", "Ruokaraha" )
  end

  def savegroups( groups, status )
    names = ""
    if groups != nil
      groups.each_pair do |key,value|
        if value == "1" && status == "Vanha"
          group = Persongroup.find(key)
          group.add( @person, Statusname.find_by_name( status ) )
          names += group.name + " "
	      else
          group = Persongroup.find(key)
          group.add( @person, Statusname.find( value ) )
          if value.to_i < -9
	    names += group.name + " "
	  end
        end
      end
    end
    return names
  end

  def shifts
    @people = []
    @group = Persongroup.find(params[:id])
    @group.people_persongroups.each { |group|
      if group != nil && group.status != nil && group.status.object_id > -2
        @people.push group.person
      end
    }
    @times = @event.times
  end

  def doshifts
    @people = []
    @times = @event.times
    @group = Persongroup.find(params[:group])
    @group.people_persongroups.each { |group|
      if group != nil && group.status != nil && group.status.object_id > -2
        @people.push group.person
        i = @event.starttime - 3*3600
        for time in @times
          g = group.person.id.to_sym
          t = time.to_sym
          slot = params[:times][g][t]
          if slot == 1
            schedule = Schedule.new
            schedule.people_persongroup = group
            schedule.starttime = i
            schedule.save
          else
            Schedule.delete(group,i)
          end
          i = i + 3600
        end
      end
    }
  end

  def reference(original)
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
      last = 10-last
    end
    return original + last.to_s 
  end

  def regeneratelist
    @mailinglist = Mailinglist.find(params[:id])
    @added = []
    for group in @mailinglist.persongroups
      if group.event_id == @event.id
	for pgroup in group.people_persongroups
	  if pgroup.status == -1
	    @added << pgroup.person
	    unless system( Rails.configuration.mailing_list_client + " subscribe " + @mailinglist.address + " " + pgroup.person.primary_email )
	      logger.fatal( "Unable to execute " + Rails.configuration.mailing_list_client + " " + "subscribe" + " " + @mailinglist.address + " " + pgroup.person.primary_email )
	      flash["email" + pgroup.person.id.to_s] = "Virhe lisattaessa henkiloa postilistalle " + @mailinglist.name
	    end
	  end
	end
      end
    end
  end
end
