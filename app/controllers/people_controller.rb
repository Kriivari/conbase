class PeopleController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  def search
  end

  def results
    @people = []
    extra = params[:extra]
    if extra != nil && extra == "yes"
      @group = Persongroup.first(:conditions => ["name='Varatyövoima' and event_id=?", @event.id])
      @people = Person.find_by_sql(["select distinct people.* from people, people_persongroups where people.id=people_persongroups.person_id and people_persongroups.persongroup_id=? order by lastname, firstname", @group.id])
    else
      name = "%"
      if params[:name] != nil
        name = params[:name].downcase + "%"
      end
      if params[:currentyear] != nil && params[:currentyear] == "yes"
	      @people = Person.find_by_sql(["select distinct people.* from people where (lower(firstname) like ? or lower(lastname) like ? or lower(nickname) like ? or primary_email like ? or primary_phone like ? or id in (select person_id from people_events_attributes where event_id=? and (value like ? or notes like ?))) and (id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id=?)) or id in (select person_id from programs_organizers where program_id in (select id from programs where event_id=?)))", name, name, name, name, name, @event.id, name, name, @event.id, @event.id])
	      if @people == nil || @people.length == 0
	        @people = Person.find_by_sql(["select distinct people.* from people where (lower(firstname || ' ' || lastname) like ? or lower(lastname || ' ' || firstname) like ?) and id in (select person_id from people_persongroups where personggroup_id in (select id from persongroups where event_id=?))", name, name, @event.id ])
	      end
      else
	      @people = Person.find_by_sql(["select distinct people.* from people where (lower(firstname) like ? or lower(lastname) like ? or lower(nickname) like ? or primary_email like ? or primary_phone like ? or id in (select person_id from people_events_attributes where event_id=? and (value like ? or notes like ?))) ", name, name, name, name, name, @event.id, name, name])
	      if @people == nil || @people.length == 0
	        @people = Person.find_by_sql(["select distinct people.* from people where (lower(firstname || ' ' || lastname) like ? or lower(lastname || ' ' || firstname) like ?)", name, name ])
	      end
      end
    end
  end

  def list
    @people = Person.paginate :page => params[:page], :order => 'lastname, firstname', :conditions => ["id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id in (select id from events where name=?)))", @event.name]
  end

  def duplicategrouplist
    @people = Person.paginate :page => params[:page], :order => 'lastname, firstname', :conditions => ["id not in (select person_id from people_persongroups where status=-1 and persongroup_id in (select id from persongroups where event_id=? and days=3 and food=2)) and id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id=?)) and id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where event_id=?) and status=-1 group by person_id having count(id)>1)", @event.id, @event.id, @event.id]
    render :action => 'list'
  end

  def show
    @person = Person.find(params[:id])
    @groups = PeoplePersongroup.find_by_sql(["select distinct people_persongroups.*, persongroups.*, events.* from people_persongroups,persongroups,events where events.id=persongroups.event_id and persongroups.id=people_persongroups.persongroup_id and person_id=? order by events.starttime desc", params[:id]])
    @attributes = PeopleEventsAttribute.find_by_sql(["select distinct people_events_attributes.*, events.* from people_events_attributes,events where events.id=people_events_attributes.event_id and person_id=? order by events.starttime desc", params[:id]])
    @programs = ProgramsOrganizer.find_by_sql(["select distinct programs_organizers.*, programs.*, events.* from programs_organizers,programs,events where events.id=programs.event_id and programs.id=programs_organizers.program_id and person_id=? order by events.starttime desc", params[:id]])
  end

  def new
    @person = Person.new
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_list')
    @person = Person.new(params[:person])
    if @person.save
      flash[:notice] = 'Henkilö luotu.'
      redirect_to :action => 'show', :id => @person.id
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
    @groups = Persongroup.all(:conditions => "event_id=" + @event.id.to_s, :order => "name").map { |g| [g.name, g.id] }
    @groups = [['Ei uutta ryhmää', 0]] + @groups
    @attributes = Attribute.all(:conditions => "person=true")
  end

  def rmgroup
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_list')
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    PeoplePersongroup.delete(params[:groupid])
    redirect_to :action => 'edit', :id => params[:persid]
  end

  def rmattribute
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_list')
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    att = PeopleEventsAttribute.find(params[:id])
    person = att.person
    att.destroy
    redirect_to :action => 'edit', :id => person.id
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_list')
    expire_fragment('staff_tickets')
    expire_fragment('staff_foods')
    @attributes = Attribute.all(:conditions => "person=true")
    @groups = @event.persongroups.map { |g| [g.name, g.id] }
    @groups = [['Ei uutta ryhmää', 0]] + @groups
    @person = Person.find(params[:id])

    if params[:primary_email]
      p = Person.find_by_primary_email(params[:primary_email].downcase.strip)
      if p.id == @person.id
        flash[:notice] = 'Tällä sähköpostiosoitteella on jo henkilö kannassa: ' + p.fullname
      end
    end

    if params[:grp][:value] != '0'
      group = Persongroup.find(params[:grp][:value])
      group.add( @person, Statusname.find_by_name("Vahvistettu") )
      if @event.slack_token && group.admin
        response = RestClient.get( "https://slack.com/api/users.admin.invite", {:params => {:token => @event.slack_token, :email => @person.primary_email}})
        if response.code != 200
          flash[:slack] = "Slack-kutsun lähetys epäonnistui. Code: " + response.code + ", viesti: " + response.body
        end
      end
    end

    for attribute in @attributes
      attsym = ("att" + attribute.id.to_s).to_sym
      if params[attsym][:value] != '0'
        value = AttributeValue.find(params[attsym][:value]).value
        attribute.add( @event, @person, value, params[attsym][:notes] )
      end
    end

    if params[:password] != nil && params[:password].length > 0
      @person.password = Person.hash_password( params[:password] )
    end

    if @person.update_attributes(params[:person])
      flash[:notice] = 'Henkilön tiedot päivitetty.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_list')
    admin = Persongroup.find_by_name( "Tuki", :conditions => ["event_id=?", @event.id] )
    unless admin.ingroup( Person.find(session[:user_id]) )
      flash[:notice] = 'Vain ylläpito voi poistaa ihmisiä'
      redirect_to :action => 'list'
      return
    end
    Person.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def duplicates
    @persons = Person.all(:order => "lastname, firstname")
    @people = []
    @duplicates = {}
    for staff in @persons
      duplicate = Person.find_by_sql(["select distinct people.* from people where firstname = ? and lastname = ? and id != ?", staff.firstname, staff.lastname, staff.id])
      if duplicate != nil && duplicate.size > 0
        @duplicates[staff.id] = duplicate
        @people << staff
      end
    end
  end

  def merge
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('staff_list')
    remain = Person.find(params[:id])
    old = Person.find(params[:duplicate])
    if remain.primary_email == nil
      remain.primary_email = old.primary_email
    end
    if remain.primary_phone == nil
      remain.primary_phone = old.primary_phone
    end
    if remain.photo_url == nil
      remain.photo_url = old.photo_url
    end
    if remain.street == nil
      remain.street = old.street
    end
    if remain.zipcode == nil
      remain.zipcode = old.zipcode
    end
    if remain.city == nil
      remain.city = old.city
    end
    if remain.country == nil
      remain.country = old.country
    end
    if old.notes != nil && ! old.notes.empty?
      if remain.notes == nil || remain.notes.empty?
        remain.notes = old.notes
      else
        remain.notes = remain.notes + " [" + old.notes + "]"
      end
    end
    if old.cv != nil && ! old.cv.empty?
      if remain.cv == nil || remain.cv.empty?
        remain.cv = old.cv
      else
        remain.cv = remain.cv + " [" + old.cv + "]"
      end
    end
    
    for group in old.people_persongroups
      group.person = remain
      group.save
    end
    for att in old.people_events_attributes
      att.person = remain
      att.save
    end
    for org in old.programs_organizers
      org.person = remain
      org.save
    end
    for order in old.orders
      order.person = remain
      order.save
    end

    remain.save
    old.destroy
    if params[:from] == "staff/list"
      redirect_to :controller => 'staff', :action => 'list'
    else
      redirect_to :action => 'duplicates'
    end
  end

  def attribute
    @attribute = Attribute.find(params[:id])
    @attributes = PeopleEventsAttribute.find_by_sql(["select people_events_attributes.* from people_events_attributes,people where attribute_id=? and event_id=? and people.id=person_id order by people.lastname, people.firstname", params[:id], @event.id])
  end
end
