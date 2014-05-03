class EventsController < Application
  before_filter :authorize

  # GET /events
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @events = Event.paginate :page => params[:page], :order => 'starttime DESC'
  end

  # GET /events/1
  def show
    @event = Event.find(params[:id])
    @missing = Person.find_by_sql(["select people.* from people where id in (select person_id from people_persongroups where status is null and persongroup_id in (select id from persongroups where event_id=?))", @event.id])
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # POST /events
  def create

    @event = Event.new(params[:event])
    @event.ispublic = false

    # Current is the public one, if the name matches. If the name doesn't
    # match, try to find latest non-public. If there are no old versions,
    # use the public one, but be careful with it.
    current = Event.first(:conditions => ["ispublic=true and name=?", @event.name])
    if current == nil
      current = Event.first(:conditions => ["name=? and year=(select max(year) from events where name=?)", @event.name, @event.name])
    end
    if current == nil
      current = Event.first(:conditions => "ispublic=true")
    end

    if current.name == @event.name

      # First copy all the groups
      current.persongroups.each { |group|
        persongroup = Persongroup.new
        persongroup.event = @event
        persongroup.name = group.name
        persongroup.mailinglist = group.mailinglist
        persongroup.visible = group.visible
        persongroup.continues = group.continues
        persongroup.days = group.days
        persongroup.food = group.food
        persongroup.notes = group.notes
        persongroup.insurance = group.insurance
        persongroup.admin = false
        if group.continues
          group.people_persongroups.each { |pg|
            p = PeoplePersongroup.new
            p.person = pg.person
            p.persongroup = persongroup
            p.status = -1
            p.save
          }
          persongroup.admin = group.admin
        else
          if group.admin
            group.admin = false
            persongroup.admin = true
            group.save
          end
        end
        persongroup.save
      }

      # Copy locations
      current.locations.each { |location|
	l = Location.new
	l.event = @event
	l.name = location.name
	l.notes = location.notes
	l.start_time = @event.starttime
	l.end_time = @event.endtime
	l.multiple = location.multiple
	l.save
      }
      # Finally change the new event to be the current one
      current.ispublic = false
      @event.ispublic = true
      current.save
    else
      # This is a new thing, just copy the basic admin account and group
      conitea = Persongroup.new
      conitea.event = @event
      conitea.name = "Conitea"
      conitea.visible = false
      conitea.continues = true
      conitea.days = 0
      conitea.food = 0
      conitea.save
      peoplegroup = PeoplePersongroup.new
      peoplegroup.person_id = 1
      peoplegroup.persongroup = conitea
      peoplegroup.status = -1
      peoplegroup.save
    end

    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # PUT /events/1
  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => 'show', :id => @event
    else
      render :action => 'edit'
    end
  end

  # DELETE /events/1
  def destroy
    Event.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
